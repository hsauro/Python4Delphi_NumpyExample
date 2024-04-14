unit uExamples;

// Simple objects to store the examples.

interface

Uses SysUtils, Classes, Generics.Collections, REST.Json;

type
  TExample = class (TObject)
     fname : string;
     fexampleStr : string;
     property name : string read fname write fname;
     property exampleStr : string read fexampleStr write fexampleStr;
     constructor Create (name, exampleStr : string);
  end;

  // It was done this way allow use to use it to automatically
  // read and write the object as a json file. Subsequently
  // the json file wasn't because it was twwo tedious to edit
  // but the structure of the object remained.
  TExamples = class (TObject)

     felements : TList<TExample>;    // The 'f' ensures it can be serialized/deserialized to json
     property elements : TList<TExample> read felements write felements;
     constructor Create;
     destructor Destroy; override;
  end;

var examples : TExamples;


implementation

constructor TExamples.Create;
begin
  inherited;
  felements := TList<TExample>.Create;
end;


destructor TExamples.Destroy;
begin
  felements.Free;
  inherited;
end;


constructor TExample.Create (name, exampleStr : string);
begin
  inherited Create;
  fname := name;
  fexampleStr := exampleStr;
end;


end.
