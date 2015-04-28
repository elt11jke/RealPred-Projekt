try 
    mex -largeArrayDims array_to_binary_float.c
    mex -largeArrayDims array_to_binary_double.c
    mex -largeArrayDims array_to_binary_int.c
    fprintf('QPgen successfully installed\n');
catch me
    fprintf('Could not install QPgen, make sure compilation using mex works\n');
end