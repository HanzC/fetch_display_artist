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

    if([responseCode statusCode] != 200)
    {
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        return nil;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:oResponseData options:NSJSONReadingMutableContainers error:&error];
    if (json.count > 0)
    {
        NSLog(@" *** JSON Key-results count: %lu", (unsigned long)[[json objectForKey:@"results"] count]); // Log results key count.
        //NSLog(@" *** JSON Key-results: %@", [json objectForKey:@"results"]); // Log all items from results key.
        for (int x = 0; x < [[json objectForKey:@"results"] count]; x++)
        {
            // Convert to Date Format
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"]; //en_US //en_US_POSIX
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
            dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            NSDate *formattedDate = [dateFormatter dateFromString:[[[json objectForKey:@"results"] objectAtIndex:x] objectForKey:@"releaseDate"]];
            //NSLog(@" *** JSON Key - Date:  %@", formattedDate);

            
            // Convert to String Date
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterNoStyle];
            //NSLog(@" *** Converted Date: %@", [formatter stringFromDate:formattedDate]);
            
            // Log all artist names, track names, release dates, primary genre name and track price.
            NSLog(@" *** JSON Key - Artist Name: %@, Track Name: %@, Release Date: %@, Genre Name: %@, Track Price: %@",
                  [[[json objectForKey:@"results"] objectAtIndex:x] objectForKey:@"artistName"],
                  [[[json objectForKey:@"results"] objectAtIndex:x] objectForKey:@"trackName"],
                  [formatter stringFromDate:formattedDate],
                  [[[json objectForKey:@"results"] objectAtIndex:x] objectForKey:@"primaryGenreName"],
                  [[[json objectForKey:@"results"] objectAtIndex:x] objectForKey:@"trackPrice"]);
        }
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
