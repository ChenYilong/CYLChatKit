// Credit: adapted from Mp3Recorder (third-party source). Renamed CYLMp3Recorder with its file, following the CYL naming rule
// (AGENTS.md, docs/naming.md).
//
//  CYLMp3Recorder.h
//  BloodSugar
//
//  v2.1.1 Created by PeterPan on 14-3-24.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CYLMp3RecorderDelegate <NSObject>
- (void)failRecord;
- (void)beginConvert;
- (void)endConvertWithMP3FileName:(NSString *)fileName;
- (void)realTimeVolumeSize:(float)size timeLength:(NSTimeInterval)timeLength;
@end

@interface CYLMp3Recorder : NSObject
@property (nonatomic, weak) id<CYLMp3RecorderDelegate> delegate;

- (id)initWithDelegate:(id<CYLMp3RecorderDelegate>)delegate;
- (void)startRecord;
- (void)stopRecord;
- (void)cancelRecord;

@end
