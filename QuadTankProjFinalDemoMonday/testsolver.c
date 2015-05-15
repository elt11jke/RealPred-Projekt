/* Produced by CVXGEN, 2015-05-11 07:52:49 -0400.  */
/* CVXGEN is Copyright (C) 2006-2012 Jacob Mattingley, jem@cvxgen.com. */
/* The code in this file is Copyright (C) 2006-2012 Jacob Mattingley. */
/* CVXGEN, or solvers produced by CVXGEN, cannot be used for commercial */
/* applications without prior written permission from Jacob Mattingley. */

/* Filename: testsolver.c. */
/* Description: Basic test harness for solver.c. */
#include "solver.h"
#include <stdio.h>
#include <jni.h>
#include "CVXGENController.h"


Vars vars;
Params params;
Workspace work;
Settings settings;
#define NUMTESTS 0
JNIEXPORT jdoubleArray JNICALL Java_CVXGENController_controlSignalCVXGEN
  (JNIEnv * env, jobject thisObj, jdoubleArray inJNIArray){
  int num_iters;

#if (NUMTESTS > 0)
  int i;
  double time;
  double time_per;
#endif

  set_defaults();
  setup_indexing();
  load_default_data();
  /* Solve problem instance for the record. */
  settings.verbose = 1;


    //Convert the Array from JNI data type to C data type

    jdouble *inCArray = (*env)->GetDoubleArrayElements(env, inJNIArray, NULL);
    if (NULL == inCArray) return NULL;
    jsize length = (*env)->GetArrayLength(env, inJNIArray);

    params.xe_0[0] = inCArray[0];
     params.xe_0[1] = inCArray[1];
     params.xe_0[2] = 0;
     params.xe_0[3] = 0;
     params.xe_0[4] = inCArray[4];
     params.xe_0[5] = inCArray[5];
     params.r[0] = inCArray[6];
     params.r[1] = inCArray[7];
     

     //printf("%f\n", inCArray[4]); TODO remove maybe
     //printf("%f\n", inCArray[5]); TODO remove maybe

     //Solve the QP
     num_iters = solve();

  //gettting the data after solving the QP
  //jdouble x = *vars.x[1];
  //jdouble x1 = *vars.x[2];

    //jdouble u0 = *vars.u_0;
    //jdouble u1 = *(vars.u_0+1);

   jdouble u1 = vars.u_0[0];
   jdouble u2= vars.u_0[1];

  jdouble controlArray[] ={u1 ,u2};

   //printf("%f\n", x);

   //printf("Hello");




  /*
#ifndef ZERO_LIBRARY_MODE
#if (NUMTESTS > 0)
  /* Now solve multiple problem instances for timing purposes. */
  /*
  settings.verbose = 0;
  tic();
  for (i = 0; i < NUMTESTS; i++) {
    solve();
  }
  time = tocq();
  printf("Timed %d solves over %.3f seconds.\n", NUMTESTS, time);
  time_per = time / NUMTESTS;
  if (time_per > 1) {
    printf("Actual time taken per solve: %.3g s.\n", time_per);
  } else if (time_per > 1e-3) {
    printf("Actual time taken per solve: %.3g ms.\n", 1e3*time_per);
  } else {
    printf("Actual time taken per solve: %.3g us.\n", 1e6*time_per);
  }
#endif
#endif
*/

   jdoubleArray outJNIArray = (*env)->NewDoubleArray(env, 2);  // allocate
   if (NULL == outJNIArray) return NULL;
   (*env)->SetDoubleArrayRegion(env, outJNIArray, 0 , 2, controlArray);  // copy
   return outJNIArray;

}
void load_default_data(void) {

  params.r[2] = 0;
  params.r[3] = 0;
  params.r[4] = 0;
  params.r[5] = 0;
  /* Make this a diagonal PSD matrix, even though it's not diagonal. */
  params.Q[0] = 5;
  params.Q[6] = 0;
  params.Q[12] = 0;
  params.Q[18] = 0;
  params.Q[24] = 0;
  params.Q[30] = 0;
  params.Q[1] = 0;
  params.Q[7] = 5;
  params.Q[13] = 0;
  params.Q[19] = 0;
  params.Q[25] = 0;
  params.Q[31] = 0;
  params.Q[2] = 0;
  params.Q[8] = 0;
  params.Q[14] = 5;
  params.Q[20] = 0;
  params.Q[26] = 0;
  params.Q[32] = 0;

  params.Q[3] = 0;
  params.Q[9] = 0;
  params.Q[15] = 0;
  params.Q[21] = 5;
  params.Q[27] = 0;
  params.Q[33] = 0;
  params.Q[4] = 0;
  params.Q[10] = 0;
  params.Q[16] = 0;
  params.Q[22] = 0;
  params.Q[28] = 5;
  params.Q[34] = 0;

  params.Q[5] = 0;
  params.Q[11] = 0;
  params.Q[17] = 0;
  params.Q[23] = 0;
  params.Q[29] = 0;
  params.Q[35] = 5;
  /* Make this a diagonal PSD matrix, even though it's not diagonal. */
  params.R[0] = 90;
  params.R[2] = 0;
  params.R[1] = 0;
  params.R[3] = 90;
  params.Ade[0] = 0.9708;
  params.Ade[1] = 0;
  params.Ade[2] = 0.2466;
  params.Ade[3] = 0;
  params.Ade[4] = 0.1126;
  params.Ade[5] = 0.0072;
  params.Ade[6] = 0;
  params.Ade[7] = 0.9689;
  params.Ade[8] = 0;
  params.Ade[9] = 0.4032;
  params.Ade[10] = 0.0108;
  params.Ade[11] = 0.1061;
  params.Ade[12] = 0;
  params.Ade[13] = 0;
  params.Ade[14] = 0.7495;
  params.Ade[15] = 0;
  params.Ade[16] = 0;
  params.Ade[17] = 0.0482;
  params.Ade[18] = 0;
  params.Ade[19] = 0;
  params.Ade[20] = 0;
  params.Ade[21] = 0.5898;
  params.Ade[22] = 0.0381;
  params.Ade[23] = 0;
  params.Ade[24] = 0;
  params.Ade[25] = 0;
  params.Ade[26] = 0;
  params.Ade[27] = 0;
  params.Ade[28] = 1;
  params.Ade[29] = 0;
  params.Ade[30] = 0;
  params.Ade[31] = 0;
  params.Ade[32] = 0;
  params.Ade[33] = 0;
  params.Ade[34] = 0;
  params.Ade[35] = 1;
  params.Bde[0] = 0.1126;
  params.Bde[1] = 0.0072;
  params.Bde[2] = 0.0108;
  params.Bde[3] = 0.1061;
  params.Bde[4] = 0;
  params.Bde[5] = 0.0482;
  params.Bde[6] = 0.0381;
  params.Bde[7] = 0;
  params.Bde[8] = 0;
  params.Bde[9] = 0;
  params.Bde[10] = 0;
  params.Bde[11] = 0;
}
