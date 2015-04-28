#include "io64.h"
#include "mex.h"
#include <stdio.h>
#include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    /* define variables */
    double *data;
    char *file_name;
    size_t len;
    int jj;
    FILE *fp;
    size_t fw;
    int *data_int;
    
    /* check inputs */
    if (!(nrhs == 2)) {
        mexErrMsgTxt("Wrong nbr of inputs");
    } 

    /* get input data */
    data = mxGetPr(prhs[0]);
    len = mxGetM(prhs[0]);


    /* store data */
    data_int = malloc(len*sizeof(int));
    if (!data_int) {
        mexErrMsgTxt("Could not allocate memory");
    }
    
    /* store to int */
    for (jj = 0 ; jj <=  ((size_t) len-1) ; jj++ ) {
        data_int[jj] = (int) (data[jj]+0.1);
    }

    /* open file */
    file_name = mxArrayToString(prhs[1]);

    fp = fopen(file_name, "wb");
    if (!fp){
        free(data_int);
        mexErrMsgTxt("File could not open");
    }

    /* Write data to the file */
    fw = fwrite(data_int, sizeof(int), len, fp);
    if (fw != len){
        free(data_int);
        mexErrMsgTxt("Could not write to file");
     }

    /* close file stream */
    fclose(fp);

    /* free input string */
    mxFree(file_name);
    
    /* free malloced variable */
    free(data_int);
}