//
//  ViewController.m
//  iTunesData
//
//  Created by Hanz Meyer on 6/18/21.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *txtField;
@property (strong, nonatomic) IBOutlet UIButton *searchArtist;

@end

@implementation ViewController

NSDictionary *json;
NSString *artistName;
NSString *trackName;
NSString *releaseDate;
NSString *genreName;
NSString *trackPrice;
UIActivityIndicatorView *spinner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* Set Text Field Properties */
    _txtField.borderStyle = UITextBorderStyleRoundedRect;
    _txtField.font = [UIFont systemFontOfSize:18];
    _txtField.autocorrectionType = UITextAutocorrectionTypeNo;
    _txtField.keyboardType = UIKeyboardTypeDefault;
    _txtField.returnKeyType = UIReturnKeyDone;
    _txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _txtField.delegate = self;
    
    /* Set Table View Properties */
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)getDataFrom:(NSString *)artist
{
    [self.tableView reloadData];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    spinner.center = CGPointMake(self.view.center.x, self.view.center.y);
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    // making a GET request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@", artist]]; //@"https://itunes.apple.com/search?term=TheWeeknd"
    NSString *targetUrl = [NSString stringWithFormat:@"%@", url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.timeoutInterval = 15;
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:targetUrl]];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSError *error2 = nil;
        if (data!= nil)
        {
            json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error2];
            if (json.count > 0)
            {
                //NSLog(@" *** JSON Key-results count: %lu", (unsigned long)[[json objectForKey:@"results"] count]); // Log results key count.
                for (int x = 0; x < [[json objectForKey:@"results"] count]; x++)
                {
                    /*
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
                */
                }
                
                /* Reload TableView on Main Thread */
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [spinner stopAnimating];
                });
                
                if ([[json objectForKey:@"results"] count] == 0)
                {
                    /* Display Alert on Main Thread */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Artist Not Found!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault
                                                                             handler:^(UIAlertAction * action) {
                                                                             }];
                        [alert addAction:closeAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        [spinner stopAnimating];
                    });
                            
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Artist Not Found!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault
                                                                         handler:^(UIAlertAction * action) {
                                                                         }];
                    [alert addAction:closeAction];
                    [self presentViewController:alert animated:YES completion:nil];
                    [spinner stopAnimating];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                // Describes and logs the error preventing us from receiving a response
                NSLog(@"Error: %@", [error userInfo]);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[error userInfo] objectForKey:@"NSLocalizedDescription"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {
                                                                     }];
                [alert addAction:closeAction];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }] resume];
}

// Error handling delegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error == nil)
    {
        // Download from API was successful
        NSLog(@"Data Network Request Did Complete Successfully.");
    }
    else
    {
        [spinner stopAnimating];
        // Describes and logs the error preventing us from receiving a response
        NSLog(@"Error: %@", [error userInfo]);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[[error userInfo] objectForKey:@"NSLocalizedDescription"] message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        [alert addAction:closeAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)searchArtistAction:(id)sender
{
    json = nil;
    [self getDataFrom:_txtField.text];
}


#pragma mark Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    json = nil;
    [textField resignFirstResponder];
    NSLog(@" *** Entered Text: %@", textField.text);
    
    NSString *secondString = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@" *** New Text: %@", secondString);
    _txtField.text = secondString;
    [self getDataFrom:_txtField.text];
    

    return YES;
}
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    return YES;
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField{
//
//}


#pragma mark - TableView Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %ld",(long)indexPath.row];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (json.count > 0)
    {
//        NSLog(@" *** JSON Key-results count: %lu", (unsigned long)[[json objectForKey:@"results"] count]); // Log results key count.
        {
            // Convert to Date Format
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"]; //en_US //en_US_POSIX
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
            dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            NSDate *formattedDate = [dateFormatter dateFromString:[[[json objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"releaseDate"]];
            //NSLog(@" *** JSON Key - Date:  %@", formattedDate);
            
            // Convert to String Date
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterNoStyle];
            //NSLog(@" *** Converted Date: %@", [formatter stringFromDate:formattedDate]);
            
            // Log all artist names, track names, release dates, primary genre name and track price.
//            NSLog(@" *** JSON Key - Artist Name: %@, Track Name: %@, Release Date: %@, Genre Name: %@, Track Price: %@",
//                  [[[json objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"artistName"],
//                  [[[json objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"trackName"],
//                  [formatter stringFromDate:formattedDate],
//                  [[[json objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"primaryGenreName"],
//                  [[[json objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"trackPrice"]);
            
            // Initialize Artist Name Label
            UILabel *artistName = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, _tableView.frame.size.width - 25, 20)];
            artistName.font =  [UIFont fontWithName:@"Arial-BoldMT" size:15];
            artistName.backgroundColor = [UIColor greenColor];
            artistName.text = [[[json objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"artistName"];
            artistName.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:artistName];
            
            // Initialize Artist Name Label
            UILabel *trackName = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(artistName.frame) + 2, _tableView.frame.size.width - 25, 25)];
            trackName.font =  [UIFont fontWithName:@"Arial" size:14];
            trackName.backgroundColor = [UIColor yellowColor];
            trackName.text = [[[json objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"trackName"];
            trackName.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:trackName];
            
            // Initialize Release Date Label
            UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(trackName.frame) + 2, _tableView.frame.size.width/2 + 25, 25)];
            date.font =  [UIFont fontWithName:@"Arial" size:14];
            date.backgroundColor = [UIColor yellowColor];
            date.text = [formatter stringFromDate:formattedDate];
            date.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:date];
            
            // Initialize Genre Name Label
            UILabel *genre = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(date.frame) + 2, _tableView.frame.size.width/2 + 25, 25)];
            genre.font =  [UIFont fontWithName:@"Arial" size:14];
            genre.backgroundColor = [UIColor yellowColor];
            genre.text = [[[json objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"primaryGenreName"];
            genre.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:genre];
            
            // Initialize Track Price Label
            UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(genre.frame) + 2, _tableView.frame.size.width/2 + 25, 25)];
            price.font =  [UIFont fontWithName:@"Arial" size:14];
            price.backgroundColor = [UIColor yellowColor];
            price.text = [NSString stringWithFormat:@"%@", [[[json objectForKey:@"results"] objectAtIndex:indexPath.row] objectForKey:@"trackPrice"]];
            price.adjustsFontSizeToFitWidth = YES;
            [cell.contentView addSubview:price];
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@" *** JSON count: %lu", (unsigned long)[[json objectForKey:@"results"] count]);
    return [[json objectForKey:@"results"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     return 140;
 }


@end
