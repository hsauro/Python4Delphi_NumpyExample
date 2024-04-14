# Python4Delphi_NumpyExample
Sample code showing how to use [Delphi4Python](https://github.com/pyscripter/python4delphi) to export a Delphi class object whose methods can be called from Python. It shows the used of [Python buffers](https://docs.python.org/3/c-api/buffer.html) to handle [numpy](https://numpy.org/) arrays and include both receiving numpy arrays from python as well as returning numpy arrays back to a python call. The current code depends on python 3.11 and uses the [embedded python](https://www.python.org/downloads/release/python-3119/) as an example. These can be easily changed to other python versions  including python installations already on a users machine. Currently the code has only be tested on Windows using Delphi 11.1. The code was compiles using 64-bit. 

The code assumes that the python distibution is in the directory called 'Python' relative to the Delphi executable. 

```      
Win64/
├─ Delphi4Python.exe
├─ Python/
│  ├─ Python files
```

This code requries the latest distribution of [Delphi4Python](https://github.com/pyscripter/python4delphi). It will **not** work with the version that gets installed from Getit. 
