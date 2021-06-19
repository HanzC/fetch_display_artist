//
//  iTunesDataTests.m
//  iTunesDataTests
//
//  Created by Hanz Meyer on 6/18/21.
//

#import <XCTest/XCTest.h>

@interface iTunesDataTests : XCTestCase

@end

@implementation iTunesDataTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    /*
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/search?term=TheWeeknd"]; //https://itunes.apple.com/search?term={any ArtistName}
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *data = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSError *erro = nil;
        if (data!=nil)
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&erro ];

            if (json.count > 0)
            {
                for(int i = 0; i<10 ; i++)
                {
                    [arr addObject:[[[json[@"feed"][@"entry"] objectAtIndex:i]valueForKeyPath:@"im:image"] objectAtIndex:0][@"label"]];
                }
            }
        }
        dispatch_sync(dispatch_get_main_queue(),^{
            //[table reloadData];
            NSLog(@" *** Data received: %@", arr);
        });
    }];
    [data resume];
    */
    
    /*
    // making a GET request
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/search?term=TheWeeknd"];
    NSString *targetUrl = [NSString stringWithFormat:@"%@", url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {

          NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          NSLog(@" *** Data received: %@", myString);
    }] resume];
    */
    
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/search?term=TheWeeknd"];
    [self getDataFrom:[NSString stringWithFormat:@"%@", url]];
}

- (NSString *)getDataFrom:(NSString *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];

    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;

    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];

    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        return nil;
    }

    NSString *newString = [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
    NSLog(@" *** Data received: %@", newString);
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
