#include <stdio.h>
#include <string.h>
#include "mex.h"
#include "matrix.h"

 void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    /* define variables */
    double *data;
    char *file_name;
    size_t len;
    FILE *fp;
    size_t fw;


    /* check inputs */
    if (!(nrhs == 2)) {
       mexErrMsgTxt("Wrong nbr of inputs");
    } 

    /* get data */
    data = mxGetPr(prhs[0]);
    len = mxGetM(prhs[0]);

    /* open file */
    file_name = mxArrayToString(prhs[1]);

    fp = fopen(file_name, "wb");
    if (!fp){
         mexErrMsgTxt("File could not open");
    }

    /* Write data to the file */
    fw = fwrite(data, sizeof(double), len, fp);
    if (fw != len){
        mexErrMsgTxt("Could not write to file");
    }

    /* close file stream */
    fclose(fp);
    
    /* free input string */
    mxFree(file_name);
}
