//
//  Storyboard.m
//  CapacitorSplashscreen
//
//  Created by Aparajita on 10/23/20.
//

#import <Foundation/Foundation.h>
#include "Storyboard.h"

@implementation Storyboard : NSObject

+(UIStoryboard *) getStoryboardNamed:(NSString *) name {
  @try {
    return [UIStoryboard storyboardWithName:[name stringByDeletingPathExtension] bundle:nil];
  } @catch (NSException *exception) {
    return nil;
  }
}

@end
