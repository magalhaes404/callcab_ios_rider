/**
 * YSSupport.m
 *
 * @package NewTaxi
 * @subpackage Controller
 * @author Seentechs Product Team
 *
 * @link http://seentechs.com
 */

#import "YSSupport.h"
#import "Reachability.h"
#import "NewTaxi-Bridging-Header.h"

//#import <FBSDKLoginKit/FBSDKLoginManager.h>
//#import <FBSDKLoginKit/FBSDKLoginManagerLoginResult.h>
//#import <FBSDKCoreKit/FBSDKAccessToken.h>
//#import <FBSDKCoreKit/FBSDKGraphRequest.h>

@implementation YSSupport


+ (void)facebookInfoDisplayForRegistration  {
}

#pragma mark - Support
//for prevoious pattern
+ (UIImage *) getScreenShot : (UIView *) view{
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}

+ (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Web Requests
//check network reachibility
+ (BOOL) isNetworkRechable {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus == NotReachable)
    {
        return NO;
    }
    return !(networkStatus == NotReachable);
}

+(NSString *)getDeviceToken
{
    if (TARGET_IPHONE_SIMULATOR)
    {
        return @"94c8a93426e12a874c8e9355da737a15db2f4a1da0d9c38de7340e8f66812b34";
    }
    else
    {
        return [[NSUserDefaults standardUserDefaults] valueForKey:USER_DEVICE_TOKEN];
    }
}

+(BOOL)checkDeviceType
{
    return (TARGET_IPHONE_SIMULATOR) ? NO : YES;
}

/*
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please check Network...", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil, nil];
 [alert show];
 */
//get structured array

+ (NSMutableArray  *)getStacturedArrayForDisplayingUserFromArray:(NSArray *)array withNoOfImageBunch:(int)NoOfImageBunch

{
    NSInteger startIndex  =   0;
    NSInteger length      =   0;
//    NSLog(@"%@", array);
    NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:0];
    
    if ([array count] > 0)
    {
        NSMutableArray *arrTemp = [NSMutableArray arrayWithCapacity:0];
        if (array.count <= NoOfImageBunch)
        {
            for (id object in array)
            {
                [arrTemp addObject:object];
            }
            [finalArray addObject:arrTemp];
        }
        else
        {
            for (int i = 0; i < (array.count / NoOfImageBunch); i++)
            {
                NSRange rangeForArrayDta = NSMakeRange( startIndex, NoOfImageBunch);
                NSArray *itemsForView = [array subarrayWithRange: rangeForArrayDta];
                [finalArray addObject:[itemsForView mutableCopy]];
                startIndex += NoOfImageBunch;
            }
            if (array.count > startIndex)
            {
                length = array.count - startIndex;
                NSRange rangeForArrayDta = NSMakeRange( startIndex, length);
                NSArray *itemsForView = [array subarrayWithRange: rangeForArrayDta];
                [finalArray addObject:[itemsForView mutableCopy]];
            }
        }
    }
    return finalArray;
}


+ (BOOL) validateEmail: (NSString *) candidate
{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}




+ (void) runSpinAnimationOnView:(UIView*)view
                       duration:(CGFloat)duration
                      rotations:(CGFloat)rotations
                         repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

//[self performSelector:@selector(fooFirstInput:)
//withObject:arrayOfThingsIWantToPassAlong
//afterDelay:15.0];

+ (void)runDelaySpinAnimationOnView:(UIView*)view
                       duration:(CGFloat)duration
                      rotations:(CGFloat)rotations
                         repeat:(float)repeat;
{
   
    NSDictionary *dictTopass=[NSDictionary dictionaryWithObjectsAndKeys:view,@"ViewtoAnimate",rotations,@"rotations",duration,@"duration",repeat,@"repeat",nil];
    
    [self performSelector:@selector(DelayrunSpinAnimationOnView:)
               withObject:dictTopass
               afterDelay:0.5];
}


+ (void)DelayrunSpinAnimationOnView:(NSDictionary*)Objects

{
    UIView *requiredView    =(UIView*)[Objects valueForKey:@"ViewtoAnimate"];
    CGFloat rotations       =[[Objects valueForKey:@"rotations"] floatValue];
    CGFloat duration        =[[Objects valueForKey:@"duration"] floatValue];
    float repeat            =[[Objects valueForKey:@"repeat"] floatValue];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [requiredView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

//+(void)resetDefaultsLogout:(BOOL)isAccountDelete {
//    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
//    NSDictionary * dict = [defs dictionaryRepresentation];
//    for (id key in dict) {
//        if (isAccountDelete) {
//            [defs removeObjectForKey:key];
//        }
//        else
//        {
//        if (![key isEqualToString:CEO_RememberMe] && ![key isEqualToString:CEO_Email] && ![key isEqualToString:CEO_Password])
//        [defs removeObjectForKey:key];
//        }
//    }
//    [defs synchronize];
//}


//+(void)resetDefaultsLogout:(BOOL)isAccountDelete {
//    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
//    NSDictionary * dict = [defs dictionaryRepresentation];
//    for (id key in dict) {
//        if (isAccountDelete) {
//            if (![key isEqualToString:APPPUSHALLOWED] || ![key isEqualToString:APPINSTALLEDFIRSTTIME])
//                [defs removeObjectForKey:key];
//        }
//        else
//        {
//            
//            if (![key isEqualToString:APPPUSHALLOWED] || ![key isEqualToString:APPINSTALLEDFIRSTTIME])
//            {
//                [defs removeObjectForKey:key];
//                
//            }
//            else if (![key isEqualToString:CEO_RememberMe] && ![key isEqualToString:CEO_Email] && ![key isEqualToString:CEO_Password])
//                [defs removeObjectForKey:key];
//        }
//    }
//    [defs synchronize];
//}


+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *) getFormatedNumber : (NSString *) number
{
    
    NSNumberFormatter *indCurrencyFormatter = [[NSNumberFormatter alloc] init];
    [indCurrencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [indCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
    NSString *formattedString =  [indCurrencyFormatter stringFromNumber:[NSNumber numberWithLongLong:[number longLongValue]]];
    return formattedString;
    
    
}
#pragma mark - Server PointSystem

+(NSMutableAttributedString *)getDollarScreen : (NSString *) final withStringToCheck:(NSString *) checkString
{
    
    
    // NSString *final = [NSString stringWithFormat:@"It will take $ 51,114 C-Bucks to pass Level 57."];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image             = [UIImage imageNamed:@"icon_cbucks_black_office"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    
    NSString *rangeString = final;
    NSRange range1 ;
    range1 = [rangeString rangeOfString:checkString];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:final];
    @try {
        [str replaceCharactersInRange:range1 withAttributedString:attachmentString];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    return str;
}
//==============================================================================

+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark --
#pragma mark Get Mint Types


+(NSString *)getCurrentDate
{
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/YYYY"];
    NSString *resultString = [dateFormatter stringFromDate: currentTime];
    return resultString;

}


+(NSString*)replaceColonAndlastComa:(NSString*)string1
{
    NSArray *arr1 = [[NSArray alloc]init];
    NSArray *arrname = [string1 componentsSeparatedByString:@":"];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
//    NSLog(@"%@",arrname);
    for (int i=0;i<[arrname count];i++)
    {
        if (i == [arrname count]-1) {
            if ([[[arrname objectAtIndex:i] lowercaseString] containsString:@"and"])
            {
                [arr addObject:[NSString stringWithFormat:@"%@",[arrname objectAtIndex:i]]];
            }
            else
                [arr addObject:[NSString stringWithFormat:@" and%@",[arrname objectAtIndex:i]]];
        }
        else
            [arr addObject:[NSString stringWithFormat:@"%@",[arrname objectAtIndex:i]]];
    }
    arr1 = arr;
    NSMutableString *gy = [[NSMutableString alloc]init];
    for (int i=0;i<[arr1 count];i++)
    {
        if (i == [arr1 count])
        {
            if ([[[arr1 objectAtIndex:i] lowercaseString] containsString:@"and"])
            {
                [gy appendString:[NSString stringWithFormat:@"%@",[arr1 objectAtIndex:i]]];
            }
            else
                [gy appendString:[NSString stringWithFormat:@"and %@",[arr1 objectAtIndex:i]]];
        }
        else if(i == 0)
            [gy appendString:[arr1 objectAtIndex:i]];
        else
        {
            if ([[[arr1 objectAtIndex:i] lowercaseString] containsString:@","])
                [gy appendString:[NSString stringWithFormat:@"%@",[arr1 objectAtIndex:i]]];
            else
                [gy appendString:[NSString stringWithFormat:@",%@",[arr1 objectAtIndex:i]]];
        }
    }
    NSString *final = [gy stringByReplacingOccurrencesOfString:@", and" withString:@" and"];
//    NSLog(@"%@",final);
    
    return final;
}


+(void)imageViewHide:(UIView*)sview{
    for (UIView *view in sview.subviews){
        if ([view isKindOfClass:[UIScrollView class]]){
            for (UIView *view1 in view.subviews){
                if ([view1 isKindOfClass:[UILabel class]]){
                    for (UIView *view2 in view1.subviews) {
                        if ([view2 isKindOfClass:[UIButton class]]) {
                            for (UIView *view3 in view2.subviews)  {
                                if ([view3 isKindOfClass:[UIImageView class]]) {
                                    view3.alpha = 0;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

+(void)showImage:(UIButton *)button
{
    for (UIView *view in button.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]])
        {
            view.alpha = 1;
        }
    }
    
}



//+(CGFloat)getCommentTextHeight : (NSString *) commentText font:(CGFloat)fontValue
//{
//    
//    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:fontValue];
//    CGFloat commentTextHeight  = [[commentText emojizedString] boundingRectWithSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-10, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size.height;
//   // return  commentTextHeight;
//        return  (commentTextHeight > 30.0 )?30.0:commentTextHeight;
//    
//}

+(CGFloat)getStringWidth : (NSString *) str
{
    
    
    UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    CGFloat textWidth  = [str boundingRectWithSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)-40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil].size.width;
    
    return  textWidth;
    
}

//+(NSDictionary *)reverseEmojiAliases {
//    NSMutableDictionary *_revEmojiAliases2 = [NSMutableDictionary new];
////    static dispatch_once_t onceToken4;
////    
////    dispatch_once(&onceToken4, ^{
////       
////    });
////
//    for (NSString *key in [EMOJI_HASH allKeys]) {
//        _revEmojiAliases2[EMOJI_HASH[key]] = key;
//    }
//    return _revEmojiAliases2;
//}
//
//+ (NSString *)stringByReplacingEmoji:(NSString *)existingString  withDict : (NSDictionary *)emojiDict{
//    
//    __block NSMutableString* temp = [NSMutableString string];
//    [existingString enumerateSubstringsInRange: NSMakeRange(0, [existingString length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
//     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
//         const unichar hs = [substring characterAtIndex: 0];
//         NSString *replaceString = @"";
//         if ([substring isEqualToString:@"@"]) {
//             replaceString = substring;
//         }else{
//             replaceString = [emojiDict valueForKey:substring];
//             if (!replaceString) {
//                 replaceString = @":smile:";
//             }
//         }
//         if (0xd800 <= hs && hs <= 0xdbff) {
//             const unichar ls = [substring characterAtIndex: 1];
//             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
//             [temp appendString:((0x1d000 <= uc && uc <= 0x1f77f)||(0x1F900 <= uc && uc <= 0x1f9ff))? replaceString: substring];
//         } else {
//             [temp appendString: (0x2100 <= hs && hs <= 0x26ff)? replaceString: substring];
//         }
//     }];
//    return temp;
//}
+(NSString *)convertToCommaSeparatedFromArray:(NSArray*)array{
  
    return [array componentsJoinedByString:@","];
}


+ (NSDictionary*)dictionaryFromResponseData:(NSData*)responseData{
    NSDictionary* dictionary = nil;
    if (responseData ) {
        id object = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        if ([object isKindOfClass:[NSDictionary class]]){
            return object;
        }
        else
        {
            return (object)?[NSDictionary dictionaryWithObject:object forKey:@"result"]:nil;
        }
    }
    return dictionary;
}
+(NSAttributedString *)getStringWithImageAttachment:(UIImage *)img attributedString :(NSAttributedString *)attributedVal
{

    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = img;
    NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    [attrStr appendAttributedString:attrStringWithImage];
    [attrStr appendAttributedString:attributedVal];
    return attrStr;
}
+(UIColor *)randomColor
{
    CGFloat red = arc4random_uniform(255) / 255.0;
    CGFloat green = arc4random_uniform(255) / 255.0;
    CGFloat blue = arc4random_uniform(255) / 255.0;
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:0.1];
    return color;
}
+ (NSString*)escapedValue:(NSString *)originalValue
{
    NSString *escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)originalValue,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    return escaped_value;
}

+(NSString *)getVal:(NSString *)str
{
    NSString       *theString = str;
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate    *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [theString componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *names = [parts filteredArrayUsingPredicate:noEmptyStrings];
    theString = [names componentsJoinedByString:@" "];
    
    return theString;
}

////POSTActivity YOU/REQUEST notification read status update/newsfeed/activity_update_read_status
//+(void)activityUpdateReadStatus:(NSInteger)activityType
//{
//    NSData*  submitData    = [[NSString stringWithFormat:@"access_token=%@&type=%ld",GETVALUE(CEO_AccessToken),(long)activityType] dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@newsfeed/activity_update_read_status",ServerUrl]];
//    NSMutableURLRequest *submitrequest = [NSMutableURLRequest requestWithURL:url];
//    [submitrequest setHTTPMethod:@"POST"];
//    [submitrequest setHTTPBody:submitData];
//    
//    NSString *submitDta123 = [[NSString alloc]initWithData:submitData encoding:NSUTF8StringEncoding];
//    NSLog(@"My Url %@",url);
//    NSLog(@"submit data %@",submitDta123);
//    
//    [NSURLConnection sendAsynchronousRequest:submitrequest queue:[NSOperationQueue mainQueue]completionHandler:^(NSURLResponse *response, NSData* data, NSError *error)
//     {
//         NSDictionary *showroomDict = [YSSupport dictionaryFromResponseData:data];
//         NSLog(@"%@",showroomDict);
//         if ([[showroomDict valueForKey:@"StatusCode"] integerValue]) {
//             
//         }
//     }];
//}


//+(NSString *)getNewVideoUrl:(NSString *)mediaID
//{
//    if ([mediaID rangeOfString:@"|"].location == NSNotFound) {
////        return [NSString stringWithFormat:@"%@/%@.mp4",([mediaID integerValue] >=4206)?VIDEO_DIRECT_URLAWS:VIDEO_DIRECT_URL,mediaID];    // need to change the url
//        
//            return [NSString stringWithFormat:@"%@/%@.mp4",([mediaID integerValue] >=2828)?VIDEO_DIRECT_URLAWS:VIDEO_DIRECT_URL,mediaID];
//        
//        
//    } else {
//        NSArray *items = [mediaID componentsSeparatedByString:@"|"];
//        NSString *newMideaId = [items firstObject];
////        return [NSString stringWithFormat:@"%@/%@.mp4",([newMideaId integerValue] >=4206)?VIDEO_DIRECT_URLAWS:VIDEO_DIRECT_URL,[items lastObject]];
//        
//       
//         return [NSString stringWithFormat:@"%@/%@.mp4",([newMideaId integerValue] >=2828)?VIDEO_DIRECT_URLAWS:VIDEO_DIRECT_URL,[items lastObject]];    // need to change the url
//        
//        
//    }
//}

/*Get Screen Name*/

//+(NSString *)getScreenName
//{
//    NSString *screenName = nil;
//    AppDelegate *delegateApp = (AppDelegate *)[UIApplication sharedApplication].delegate;
//
//    switch (delegateApp.ysTabBarControllerSelectdIndex) {
//        case 0:
//            screenName = @"Home";
//            break;
//        case 1:
//            screenName = @"Showrooms";
//            break;
//        case 3:
//            screenName = @"Activity";
//            break;
//        case 4:
//            screenName = @"Profile";
//            break;
//            
//        default:
//            break;
//    }
//    return screenName;
//
//}

@end
