//
//  FFT.m
//  DTMFReceiver
//
//  Created by 石郷 祐介 on 2014/06/28.
//  Copyright (c) 2014年 Yusk. All rights reserved.
//

#import "FFT.h"
#import <Accelerate/Accelerate.h>

@implementation FFT
{
	vDSP_Length _log2n;
	FFTSetup _fftSetup;
	DSPSplitComplex _splitComplex;
	float *_window;
}

- (id)initWithCapacity:(NSUInteger)capacity
{
	self = [super init];
	
	if (self)
	{
		self.capacity = capacity;
		_log2n = log2f(capacity);
		
		_fftSetup = vDSP_create_fftsetup(_log2n, FFT_RADIX2);
		
		_splitComplex.realp = (float *)calloc(capacity/2, sizeof(float));
		_splitComplex.imagp = (float *)calloc(capacity/2, sizeof(float));
		
		_window = (float *)calloc(capacity, sizeof(float));
		vDSP_hamm_window(_window, capacity, 0);
	}
	
	return self;
}

- (void)process:(float *)input
{
	vDSP_vmul(input, 1, _window, 1, input, 1, self.capacity);
	vDSP_ctoz((COMPLEX*)input, 2, &_splitComplex, 1, self.capacity/2);
	vDSP_fft_zrip(_fftSetup, &_splitComplex, 1, _log2n, FFT_FORWARD);
}

- (float)spectrum:(NSUInteger)index
{
	float real = _splitComplex.realp[index];
	float imag = _splitComplex.imagp[index];
	
	return real * real + imag * imag;
}

- (void)dealloc
{
	free(_splitComplex.realp);
	free(_splitComplex.imagp);
	
	free(_window);
	
	vDSP_destroy_fftsetup(_fftSetup);
}

@end
