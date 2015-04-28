#include <stdio.h>
#include "mex.h"
#include "matrix.h"

 void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    /* define variables */
    double *data;
    char *file_name;
    size_t len;
    FILE *fp;
    size_t fw;
    float *data_float; 
    int jj; 

     /* check inputs */

    if (!(nrhs == 2)) {
        mexErrMsgTxt("Wrong nbr of inputs");
    } 

    /* get data */
    data = mxGetPr(prhs[0]);
    len = mxGetM(prhs[0]);

    /* store data in correct format */
    data_float = malloc(len*sizeof(float));
    if (!data_float) {
        mexErrMsgTxt("Could not allocate memory");
    }

    /* store to float */
    for (jj = 0 ; jj <=  ((int) len-1) ; jj++ ) {
        data_float[jj] = (float) (data[jj]);
        }

    /* open file */
    file_name = mxArrayToString(prhs[1]);

    fp = fopen(file_name, "wb");
    if (!fp){
        free(data_float);
        mexErrMsgTxt("File could not open");
     }

    /* Write data to the file */
    fw = fwrite(data_float, sizeof(float), len, fp);
    if (fw != len){
        free(data_float);
        mexErrMsgTxt("Could not write to file");
     }

    /* close file stream */
    fclose(fp);

    /* free input string */
    mxFree(file_name);

    /* free malloced variable */
    free(data_float);

}