# Python4Delphi_NumpyExample
Sample code showing how to use [Delphi4Python](https://github.com/pyscripter/python4delphi) to export a Delphi object whose methods can be called from Python. It shows the use of [Python buffers](https://docs.python.org/3/c-api/buffer.html) to handle [numpy](https://numpy.org/) arrays and includes both receiving numpy arrays from python as well as returning numpy arrays back to a python call. There are also some other examples using Lists. The current code depends on python 3.11 and uses the [embedded python](https://www.python.org/downloads/release/python-3119/) as an example. Other python versions can easily be used including python installations already on a users' machine. Currently the code has only be tested on Windows using Delphi 11.1. The code compiles to 64-bit. 

The code uses the Delphi wrapper support provided by Delphi4Python which makes it very easy to connect Delphi to Python. Two recent enhacnements include the ability to support PyObjects and Python buffers. These have made it much easier to work with numpy arrays.

The code assumes that the python distibution is in the directory called 'Python' relative to the Delphi executable. 

```      
Win64/
├─ DelphiExecutable.exe
├─ Python/
│  ├─ Python files
```

Examples are stored in the examples.txt file which uses a simple format for storing test examples and will likely horrify seasoned developers in this day and age. However, at one point I used json to store the examples (code is still in the source) but found it to be very inconvenient to add new examples using a text editor so I reverted to a simple text format instead.

I added a release binary to make it easy to try out withut having to compile the code. 

This code requries the latest distribution of [Delphi4Python](https://github.com/pyscripter/python4delphi). It will **not** work with the version that gets installed from Getit. 
