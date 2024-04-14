unit uHostAPI;

interface

Uses SysUtils, Classes, PythonEngine, WrapDelphi, VarPyth;

type
{$TYPEINFO ON}
{$METHODINFO ON}   // Must include this directive, adds more RTTI info
  ThostAPI =  class (TPersistent)
     private
      np : Variant;
     published
      function getVersion() : string;
      function add (x, y : double) : double;

      function getList : PPyObject;
      function getListUsingSetItem : PPyObject;
      function echoList (alist : PPyObject) : PPyObject;
      function appendToList (alist : PPyObject) : PPyObject;

      function accessElement1DArray (m : PPyObject; index : NativeInt) : double;

      function getNumPy : PPyObject;
      function getMatrix : PPyObject;
      function show1darrayi (m : PPyObject) : PPyObject;
      function show1darrayd (m : PPyObject) : PPyObject;
      function show2darrayd (m : PPyObject) : PPyObject;

      constructor Create;
  end;
{$METHODINFO OFF}

implementation

Uses Math;

type
  TIntArray = array[0..10000] of Integer;
  PIntArray = ^TIntArray;
  TNativeIntArray = array[0..10000] of NativeInt;
  PNativeIntArray = ^TNativeIntArray;

// Import he numpy array (I assume it is installed on your system!)
constructor ThostAPI.Create;
begin
  inherited;
  np := Import ('numpy');
end;


// It very easy to return simple types to the python caller
// e.g Returning a string
function ThostAPI.getVersion() : string;
begin
  result := '0.2';
end;


// It very easy to accept and return simple types to the python caller
function ThostAPI.add (x, y : double) : double;
begin
  result := x + y;
end;



// -------------------------------------------------------------------------------
// Examples of more comples calls including basic numpy usage


// Create a simple python list and return it
function ThostAPI.getList : PPyObject;
var py : TPythonEngine;
begin
   py := GetPythonEngine;

   result := GetPythonEngine.ArrayToPyList([1, 2, 3, py.PyBool_FromLong(integer (True)), 5, py.Py_False])
end;


// Create a list using python list append
function ThostAPI.getListUsingSetItem : PPyObject;
var py : TPythonEngine;
    alist, item : PPyObject;
    x, index : integer;
begin
   py := GetPythonEngine;

   alist := py.PyList_New (3);

   index := py.PyList_SetItem (alist, 0, py.PyFloat_FromDouble (3.414));
   index := py.PyList_SetItem (alist, 1, py.PyFloat_FromDouble (2.718));
   index := py.PyList_SetItem (alist, 2, py.PyFloat_FromDouble (1.414));

   result := alist;
end;


// Pass a list to the function and return it
function ThostAPI.echoList (alist : PPyObject) : PPyObject;
var py : TPythonEngine;
    i : integer;
    d : double;
begin
  py := GetPythonEngine;
  if not py.PyList_Check(alist) then
     raise EPythonError.Create('the python object is not a list');

  for i := 0 to py.PyList_Size (alist) - 1 do
      begin
      d := py.PyObjectAsVariant (py.PyList_GetItem(alist, i));
      py.IO.Write('d = ' + floattostr (d) + sLineBreak);
      end;
  py.Py_INCREF(alist);
  result := alist;
end;


// Given a list, append an element and return the modified list
function ThostAPI.appendToList (alist : PPyObject) : PPyObject;
var py : TPythonEngine;
begin
  py := GetPythonEngine;
  if not py.PyList_Check(alist) then
     raise EPythonError.Create('the python object is not a list');

  py.PyList_Append (alist, py.PyFloat_FromDouble (3.414));

  py.Py_INCREF(alist); // Make sure the garbage collector doesn't free alist
  result := alist;
end;


// -------------------------------------------------------------------------------


// Return a delphi array as a numpy array
function ThostAPI.getNumPy () : PPyObject;
var py : TPythonEngine;
    arr : Variant;
    i, j, nrows, ncols : integer;
    data : array of array of double;
begin
   py := GetPythonEngine;

   nrows := 4; ncols := 5;
   setlength (data, nrows, ncols);
   for i := 0 to nrows - 1 do
       for j := 0 to ncols - 1 do
           data[i, j] := RandomRange(0, 10);

   // Create a numpy array from the Delphi array
   arr := np.array(VarPythonCreate(data));
   result := ExtractPythonObjectFrom(arr);
   py.Py_IncRef(result);
end;


// Construct a 2x2 matrix and return is as a numpy array
function ThostAPI.getMatrix : PPyObject;
var py : TPythonEngine;
    nrows, ncols : integer;
    data : array of array of double;
begin
  py := GetPythonEngine;

  nrows := 2; ncols := 2;
  setlength (data, nrows, ncols);
  data[0, 0] := 2;   data[0, 1] := 1;
  data[1, 0] := 1;   data[1, 1] := 3;
  result := ExtractPythonObjectFrom(np.array(VarPythonCreate(data)));
  py.Py_XIncRef(result);
end;


// The following are examples of how to access elements in a Python buffer
// These assume the buffers hold the correct type
// One exported method, accessElement1DArray, show it in use.

function getIntValueFrom1DBuffer (buffer : Py_buffer; i : NativeInt) : integer;
var
  ptr: pointer;
begin
   ptr := PAnsiChar (buffer.buf) +  i*sizeof(integer);
   result := PInteger (ptr)^;
end;



function getDoubleValueFrom1DBuffer (buffer : Py_buffer; i : NativeInt) : double;
var
  ptr: PAnsiChar;
begin
   ptr := PAnsiChar (buffer.buf) + i*sizeof(double);
   result := PDouble (ptr)^;
end;


function getIntValueFrom2DBuffer (buffer : Py_buffer; i, j : NativeInt) : double;
var
  ptr: PAnsiChar;
  nr, nc : integer;
begin
   nr := PNativeIntArray (buffer.shape)[0];
   nc := PNativeIntArray (buffer.shape)[1];

   ptr := PAnsiChar (buffer.buf) + i*buffer.itemsize*nc + j * buffer.itemsize;
   result := PInteger (ptr)^;
end;


function getDoubleValueFrom2DBuffer (buffer : Py_buffer; i, j : NativeInt) : double;
var
  ptr: PAnsiChar;
  p1 : pointer;
  nr, nc : integer;
begin
   nr := PNativeIntArray (buffer.shape)[0];
   nc := PNativeIntArray (buffer.shape)[1];

   p1 := PAnsiChar (buffer.buf) + i * buffer.itemsize * nc + j * buffer.itemsize;
   result := PDouble (p1)^;
end;


// Pass in a numpy 1d array and access the indexth element
function ThostAPI.accessElement1DArray (m : PPyObject; index : NativeInt) : double;
var PyBuffer: Py_buffer;
    errorInt : integer;
begin
  errorInt := GetPythonEngine.PyObject_GetBuffer(m, @PyBuffer, PyBUF_C_CONTIGUOUS);
  try
    if errorInt < 0 then
        raise EPyBufferError.Create('Argument must by a numpy 1D array');

    // Check if its a 1D double array
    if PyBuffer.ndim <> 1 then
      raise EPythonError.Create('Expecting a 1D array');

    // Check that the array holds doubles
    if PyBuffer.itemsize <> sizeof (double) then
       raise EPythonError.Create('numpy array should contain double values');

    result := getDoubleValueFrom1DBuffer (PyBuffer, index);
  finally
    GetPythonEngine.PyBuffer_Release (@PyBuffer);
  end;
end;


// ---------------------------------------------------------------------------

// Pass in a 1D array of integers and return it to caller
function ThostAPI.show1darrayi (m : PPyObject) : PPyObject;
type TByteArray = array[0..256] of byte;
var py : TPythonEngine;
    PyBuffer: Py_buffer;
    nelements : integer;
    dest : array of integer;
    destByte : PByteArray;
begin
  py := GetPythonEngine;

  py.PyObject_GetBuffer(m, @PyBuffer, PyBUF_C_CONTIGUOUS);

  try
    if PyBuffer.ndim = 1 then
       begin
       if PyBuffer.itemsize = sizeof (integer) then
          begin
          nelements := PyBuffer.len div PyBuffer.itemsize;

          setlength (dest, PyBuffer.len div PyBuffer.itemsize);
          destByte := PByteArray (PyBuffer.buf);
          move (destByte[0], dest[0], PyBuffer.len);

          result := ExtractPythonObjectFrom(np.array(VarPythonCreate(dest)));
          py.Py_XIncRef(result);
          end
       else
          raise Exception.Create('NumPy array can only contain integers');
       end
    else
       raise Exception.Create('NumPy array must be one dimensional');
  finally
     py.PyBuffer_Release (@PyBuffer);
  end;
end;


// Pass in a 1D array of doubles and return it to caller
function ThostAPI.show1darrayd (m : PPyObject) : PPyObject;
type TByteArray = array[0..10000] of byte;
var py : TPythonEngine;
    PyBuffer: Py_buffer;
    nelements : integer;
    dest : array of double;
    destByte : PByteArray;
begin
  py := GetPythonEngine;

  py.PyObject_GetBuffer(m, @PyBuffer, PyBUF_C_CONTIGUOUS);

  try
    if PyBuffer.ndim = 1 then
       begin
       if PyBuffer.itemsize = sizeof (double) then
          begin
          nelements := PyBuffer.len div PyBuffer.itemsize;

          // len = total number of bytes uses
          // itemsize = size in bytes of the data element being stored, 4 for ints
          setlength (dest, PyBuffer.len div PyBuffer.itemsize);
          destByte := PByteArray (PyBuffer.buf);
          move (destByte[0], dest[0], PyBuffer.len);

          result := ExtractPythonObjectFrom(np.array(VarPythonCreate(dest)));
          py.Py_XIncRef(result);
          end
       else
          raise Exception.Create('NumPy array must contain floats');
       end
    else
       raise Exception.Create('NumPy array must be one dimensional');
  finally
     py.PyBuffer_Release (@PyBuffer);
  end;
end;


// Pass in a 2D array of doubles and return it to caller
function ThostAPI.show2darrayd (m : PPyObject) : PPyObject;
type TNativeIntArray = array[0..10000] of NativeInt;
     PNativeIntArray = ^TNativeIntArray;
var py : TPythonEngine;
    PyBuffer: Py_buffer;
    nElements : integer;
    dest : array of double;
    d2 : array of array of double;
    destByte : PByteArray;
    nr, nc : integer;
    i, j, count : integer;
begin
  py := GetPythonEngine;

  py.PyObject_GetBuffer(m, @PyBuffer, PyBUF_C_CONTIGUOUS);

  try
    if PyBuffer.ndim = 2 then
       begin
       nElements := PyBuffer.len div PyBuffer.itemsize;

       setlength (dest, PyBuffer.len div PyBuffer.itemsize);
       destByte := PByteArray (PyBuffer.buf);
       move (destByte[0], dest[0], PyBuffer.len);

       nr := PNativeIntArray (PyBuffer.shape)[0];
       nc := PNativeIntArray (PyBuffer.shape)[1];

       setLength (d2, nr, nc);
       count := 0;
       for i := 0 to nr - 1 do
           for j := 0 to nc - 1 do
               begin
               d2[i,j] := dest[count];
               inc (count);
               end;

      result := ExtractPythonObjectFrom(np.array(VarPythonCreate(d2)));
      py.Py_XIncRef(result);
       end
    else
       raise Exception.Create('NumPy array must be two dimensional');
  finally
    py.PyBuffer_Release (@PyBuffer);
  end;
end;


end.
