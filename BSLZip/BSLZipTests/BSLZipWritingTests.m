//
//  BSLZipWritingTests.m
//  BSLZip
//
//  Created by Brian Clubb on 11/12/12.
//  Copyright (c) 2012 Bubblesort Labratories. All rights reserved.
//

#import "BSLZipWritingTests.h"
#import <BSLZip/BSLZip.h>

@interface BSLZipWritingTests ()
@property NSString *documentsDir;
@property NSString *filePath;
@end

@implementation BSLZipWritingTests


- (void)setUp
{
    [super setUp];
    _documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    _filePath= [_documentsDir stringByAppendingPathComponent:@"test.zip"];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_filePath error:nil];
}

- (void)testOpeningZip{
    @try {
        NSLog(@"%@",@"Opening zip file for writing...");
        ZipFile *zipFile= [[ZipFile alloc] initWithFileName:_filePath mode:ZipFileModeCreate];
        NSLog(@"%@", @"Closing zip file...");
        [zipFile close];
    }
    @catch (ZipException *ze) {
        STFail(@"ZipException caught: %d - %@", ze.error, [ze reason]);
    } @catch (id e) {
        STFail(@"Exception caught: %@ - %@", [[e class] description], [e description]);
    }
    @finally {
        
    }
}

- (void)testAddingFileToZip{
    @try {
        NSLog(@"%@",@"Opening zip file for writing...");
        ZipFile *zipFile= [[ZipFile alloc] initWithFileName:_filePath mode:ZipFileModeCreate];
        
        NSLog(@"%@",@"Adding first file...");
        ZipWriteStream *stream1= [zipFile writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:ZipCompressionLevelBest];
        [stream1 finishedWriting];
        
        NSLog(@"%@", @"Closing zip file...");
        [zipFile close];
    }
    @catch (ZipException *ze) {
        STFail(@"ZipException caught: %d - %@", ze.error, [ze reason]);
    } @catch (id e) {
        STFail(@"Exception caught: %@ - %@", [[e class] description], [e description]);
    }
    @finally {
        
    }
}

- (void)testWritingToTheZipFile{
    @try {
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
    @catch (ZipException *ze) {
        STFail(@"ZipException caught: %d - %@", ze.error, [ze reason]);
    } @catch (id e) {
        STFail(@"Exception caught: %@ - %@", [[e class] description], [e description]);
    }
    @finally {
        
    }
}

@end
