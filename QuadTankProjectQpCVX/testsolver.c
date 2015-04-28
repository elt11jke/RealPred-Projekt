/* Produced by CVXGEN, 2015-04-14 11:15:37 -0400.  */
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

    params.x_0[0] = inCArray[0];
     params.x_0[1] = inCArray[1];
     params.x_0[2] = inCArray[2];
     params.x_0[3] = inCArray[3];
     params.r[0] = inCArray[4];
     params.r[1] = inCArray[5];
     params.r[2] = 0;
     params.r[3] = 0;

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

/*
  params.x_0[0] = 0.20319161029830202;
  params.x_0[1] = 0.8325912904724193;
  params.x_0[2] = -0.8363810443482227;
  params.x_0[3] = 0.04331042079065206;
  params.r[0] = 1.5717878173906188;
  params.r[1] = 1.5851723557337523;
  params.r[2] = -1.497658758144655;
  params.r[3] = -1.171028487447253;
  /* Make this a diagonal PSD matrix, even though it's not diagonal. */
  params.Q[0] = 1;
  params.Q[4] = 0;
  params.Q[8] = 0;
  params.Q[12] = 0;
  params.Q[1] = 0;
  params.Q[5] = 1;
  params.Q[9] = 0;
  params.Q[13] = 0;
  params.Q[2] = 0;
  params.Q[6] = 0;
  params.Q[10] = 0;
  params.Q[14] = 0;
  params.Q[3] = 0;
  params.Q[7] = 0;
  params.Q[11] = 0;
  params.Q[15] = 0;
  /* Make this a diagonal PSD matrix, even though it's not diagonal. */
  params.R[0] = 1;
  params.R[2] = 0;
  params.R[1] = 0;
  params.R[3] = 1;
  params.A[0] = 0.9708;
  params.A[1] = 0;
  params.A[2] = 0.2466;
  params.A[3] = 0;
  params.A[4] = 0;
  params.A[5] = 0.9689;
  params.A[6] = 0;
  params.A[7] = 0.4032;
  params.A[8] = 0;
  params.A[9] = 0;
  params.A[10] = 0.7495;
  params.A[11] = 0;
  params.A[12] = 0;
  params.A[13] = 0;
  params.A[14] = 0;
  params.A[15] = 0.5898;
  params.B[0] = 0.1126;
  params.B[1] = 0.0072;
  params.B[2] = 0.0108;
  params.B[3] = 0.1061;
  params.B[4] = 0;
  params.B[5] = 0.0482;
  params.B[6] = 0.0381;
  params.B[7] = 0;
  params.S[0] = 0.7231295261251562;
}
