//
//  ViewController.m
//  DTMFReceiver
//
//  Created by 石郷 祐介 on 2014/06/28.
//  Copyright (c) 2014年 Yusk. All rights reserved.
//

#import "ViewController.h"
#import "FFT.h"
#import <EZAudio.h>

@interface ViewController () <EZMicrophoneDelegate>
@property (nonatomic, weak) IBOutlet EZAudioPlot *plot;
@property (nonatomic, weak) IBOutlet UILabel *IDLbl;
@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, strong) FFT *fft;

- (void)checkDTMF:(id)sender;
- (IBAction)output:(id)sender;
@end

@implementation ViewController
{
	NSTimer *_timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.plot.backgroundColor = [UIColor colorWithRed:0.984 green:0.471 blue:0.525 alpha:1.0];
	self.plot.color = [UIColor whiteColor];
	self.plot.shouldFill = YES;
	self.plot.plotType = EZPlotTypeBuffer;

	self.microphone = [EZMicrophone microphoneWithDelegate:self startsImmediately:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.5f
											  target:self
											selector:@selector(checkDTMF:)
											userInfo:nil
											 repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	[_timer invalidate];
	_timer = nil;
}

- (void)checkDTMF:(id)sender
{
	if (self.fft)
	{
		const float THRESHOLD = 15.0f;
		
		if ([self.fft spectrum:395] > THRESHOLD && [self.fft spectrum:441] > THRESHOLD)
		{
			self.IDLbl.text = @"1";
		}
		else if ([self.fft spectrum:395] > THRESHOLD && [self.fft spectrum:453] > THRESHOLD)
		{
			self.IDLbl.text = @"2";
		}
		else if ([self.fft spectrum:395] > THRESHOLD && [self.fft spectrum:465] > THRESHOLD)
		{
			self.IDLbl.text = @"3";
		}
		else
		{
			self.IDLbl.text = @"null";
		}
	}
}

- (IBAction)output:(id)sender
{
	if (self.fft)
	{
		NSLog(@"---------------------------------");
		for (int i = 0; i < self.fft.capacity/2; i++)
		{
			NSLog(@"[%d] %f", i, [self.fft spectrum:i]);
		}
		NSLog(@"---------------------------------");
	}
}

#pragma mark -
#pragma mark EZMicrophone Delegate

- (void)microphone:(EZMicrophone *)microphone hasAudioReceived:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels
{
	__weak ViewController *wself = self;
	
	static dispatch_once_t token;
	dispatch_once(&token, ^
	{
		wself.fft = [[FFT alloc] initWithCapacity:bufferSize];
	});

	dispatch_async(dispatch_get_main_queue(), ^
	{
		[wself.fft process:buffer[0]];
		
		float amp[bufferSize/2];
		float max = 0;
		
		for (int i = 0; i < bufferSize/2; i++)
		{
			max = fmaxf(max, [wself.fft spectrum:i]);
		}

		for (int i = 0; i < bufferSize/2; i++)
		{
			amp[i] = [EZAudio MAP:[wself.fft spectrum:i]
						  leftMin:0.0 leftMax:max
						 rightMin:0.0 rightMax:1.0];
		}
		
		[wself.plot updateBuffer:amp withBufferSize:bufferSize/2];
	});
}

@end
