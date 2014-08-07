//
//  main.m
//  generate-string-symbols
//
//  Created by Daniel Kennett on 07/08/14.
//  Copyright (c) 2014 Daniel Kennett. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Usage

void printUsage() {

    NSString *processName = [[NSProcessInfo processInfo] processName];

    printf("%s by Daniel Kennett\n\n", processName.UTF8String);

    printf("Outputs a header file containing symbols for the give .strings\n");
    printf("file's keys.\n\n");

    printf("Usage: %s -out <output file path> \n", processName.UTF8String);
    printf("       %s -strings <strings file path>\n", [@"" stringByPaddingToLength:processName.length
                                                                         withString:@" "
                                                                    startingAtIndex:0].UTF8String);
    printf("\n\n");
}

#pragma mark - Main

int main(int argc, const char * argv[])
{

    @autoreleasepool {

        NSString *inputFilePath = [[NSUserDefaults standardUserDefaults] valueForKey:@"strings"];
        NSString *outputFilePath = [[NSUserDefaults standardUserDefaults] valueForKey:@"out"];

        setbuf(stdout, NULL);

        if (inputFilePath.length == 0 || outputFilePath.length == 0) {
            printUsage();
            exit(EXIT_FAILURE);
        }

        if (![[NSFileManager defaultManager] fileExistsAtPath:inputFilePath]) {
            printf("ERROR: Input file %s doesn't exist.\n", [inputFilePath UTF8String]);
            exit(EXIT_FAILURE);
        }

        NSError *error = nil;
        NSData *plistData = [NSData dataWithContentsOfFile:inputFilePath
                                                   options:0
                                                     error:&error];

        if (error != nil) {
            printf("ERROR: Reading input file failed with error: %s\n", error.localizedDescription.UTF8String);
            exit(EXIT_FAILURE);
        }

        id plist = [NSPropertyListSerialization propertyListWithData:plistData
                                                             options:0
                                                              format:nil
                                                               error:&error];

        if (error != nil) {
            printf("ERROR: Reading input file failed with error: %s\n", error.localizedDescription.UTF8String);
            exit(EXIT_FAILURE);
        }

        if (![plist isKindOfClass:[NSDictionary class]]) {
            printf("ERROR: Strings file contained unexpected root object type.");
            exit(EXIT_FAILURE);
        }

        NSMutableString *fileContents = [NSMutableString new];
        [fileContents appendString:@"#import <Foundation/Foundation.h>\n\n"];

        for (NSString *key in plist) {
            [fileContents appendString:[NSString stringWithFormat:@"static const char *%@ = \"%@\";\n", key, key]];
        }


        if (![fileContents writeToFile:outputFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
            printf("ERROR: Writing output file failed with error: %s\n", error.localizedDescription.UTF8String);
            exit(EXIT_FAILURE);
        }

        exit(EXIT_SUCCESS);

    }
    return 0;
}