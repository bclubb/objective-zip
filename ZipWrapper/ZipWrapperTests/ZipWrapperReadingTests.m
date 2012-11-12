//
//  ZipWrapperReadingTests.m
//  ZipWrapper
//
//  Created by Brian Clubb on 11/11/12.
//  Copyright (c) 2012 Bubblesort Labratories. All rights reserved.
//

#import "ZipWrapperReadingTests.h"
#import "ZipException.h"
#import "ZipFile.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"

@interface ZipWrapperReadingTests ()

@property NSString *documentsDir;
@property NSString *filePath;

@end

@implementation ZipWrapperReadingTests

-(void) setUp{
    [super setUp];
    _documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    _filePath= [_documentsDir stringByAppendingPathComponent:@"test.zip"];
    NSLog(@"%@",@"Opening zip file for writing...");
    ZipFile *zipFile= [[ZipFile alloc] initWithFileName:_filePath mode:ZipFileModeCreate];
    
    NSLog(@"%@",@"Adding first file...");
    ZipWriteStream *stream1= [zipFile writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:ZipCompressionLevelBest];
    
    NSLog(@"%@",@"Writing to first file's stream...");
    NSString *text= @"abc";
    [stream1 writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"%@",@"Closing first file's stream...");
    [stream1 finishedWriting];
    
    NSLog(@"%@", @"Adding second file...");
    ZipWriteStream *stream2= [zipFile writeFileInZipWithName:@"x/y/z/xyz.txt" compressionLevel:ZipCompressionLevelNone];
    
    NSLog(@"%@", @"Writing to second file's stream...");
    NSString *text2= @"XYZ";
    [stream2 writeData:[text2 dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"%@", @"Closing second file's stream...");
    [stream2 finishedWriting];
    
    NSLog(@"%@", @"Closing zip file...");
    [zipFile close];
}

-(void)tearDown{
    [super tearDown];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:_filePath error:&error];
}

- (void)testOpeningZipFileToRead{
    @try {
        NSLog(@"%@",@"Opening zip file for reading...");
        
        ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:_filePath mode:ZipFileModeUnzip];
        
        NSLog(@"%@", @"Reading file infos...");
        
        NSArray *infos= [unzipFile listFileInZipInfos];
        for (FileInZipInfo *info in infos) {
            NSString *fileInfo= [NSString stringWithFormat:@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level];
            NSLog(@"%@",fileInfo);
        }
        [unzipFile close];
    } @catch (ZipException *ze) {
        STFail(@"ZipException caught: %d - %@", ze.error, [ze reason]);
        
    } @catch (id e) {
        STFail(@"Exception caught: %@ - %@", [[e class] description], [e description]);
    }
}

- (void)testReadingZipFile{
    @try {
        NSLog(@"%@",@"Opening zip file for reading...");
        
        ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:_filePath mode:ZipFileModeUnzip];
        
        NSLog(@"%@", @"Reading file infos...");
        
        NSArray *infos= [unzipFile listFileInZipInfos];
        for (FileInZipInfo *info in infos) {
            NSString *fileInfo= [NSString stringWithFormat:@"- %@ %@ %d (%d)", info.name, info.date, info.size, info.level];
            NSLog(@"%@",fileInfo);
        }
        
        [self performSelectorOnMainThread:@selector(log:) withObject:@"Opening first file..." waitUntilDone:YES];
        
        [unzipFile goToFirstFileInZip];
        ZipReadStream *read1= [unzipFile readCurrentFileInZip];
        
        [self performSelectorOnMainThread:@selector(log:) withObject:@"Reading from first file's stream..." waitUntilDone:YES];
        
        NSMutableData *data1= [[NSMutableData alloc] initWithLength:256];
        int bytesRead1= [read1 readDataWithBuffer:data1];
        
        BOOL ok= NO;
        if (bytesRead1 == 3) {
            NSString *fileText1= [[NSString alloc] initWithBytes:[data1 bytes] length:bytesRead1 encoding:NSUTF8StringEncoding];
            if ([fileText1 isEqualToString:@"abc"])
                ok= YES;
        }
        
        if (ok)
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Content of first file is OK" waitUntilDone:YES];
        else
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Content of first file is WRONG" waitUntilDone:YES];
        
        [self performSelectorOnMainThread:@selector(log:) withObject:@"Closing first file's stream..." waitUntilDone:YES];
        
        [read1 finishedReading];
        
        [self performSelectorOnMainThread:@selector(log:) withObject:@"Opening second file..." waitUntilDone:YES];
        
        [unzipFile goToNextFileInZip];
        ZipReadStream *read2= [unzipFile readCurrentFileInZip];
        
        [self performSelectorOnMainThread:@selector(log:) withObject:@"Reading from second file's stream..." waitUntilDone:YES];
        
        NSMutableData *data2= [[NSMutableData alloc] initWithLength:256];
        int bytesRead2= [read2 readDataWithBuffer:data2];
        
        ok= NO;
        if (bytesRead2 == 3) {
            NSString *fileText2= [[NSString alloc] initWithBytes:[data2 bytes] length:bytesRead2 encoding:NSUTF8StringEncoding];
            if ([fileText2 isEqualToString:@"XYZ"])
                ok= YES;
        }
        
        if (ok)
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Content of second file is OK" waitUntilDone:YES];
        else
            [self performSelectorOnMainThread:@selector(log:) withObject:@"Content of second file is WRONG" waitUntilDone:YES];
        
        [self performSelectorOnMainThread:@selector(log:) withObject:@"Closing second file's stream..." waitUntilDone:YES];
        
        [read2 finishedReading];
        
        [self performSelectorOnMainThread:@selector(log:) withObject:@"Closing zip file..." waitUntilDone:YES];
        
        [unzipFile close];
        
        [self performSelectorOnMainThread:@selector(log:) withObject:@"Test terminated succesfully" waitUntilDone:YES];

        [unzipFile close];
    } @catch (ZipException *ze) {
        STFail(@"ZipException caught: %d - %@", ze.error, [ze reason]);
        
    } @catch (id e) {
        STFail(@"Exception caught: %@ - %@", [[e class] description], [e description]);
    }
}

@end
