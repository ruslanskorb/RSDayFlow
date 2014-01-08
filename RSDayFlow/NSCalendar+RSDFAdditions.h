#import <Foundation/Foundation.h>

@interface NSCalendar (RSDFAdditions)

- (NSDateFormatter *)df_dateFormatterNamed:(NSString *)name withConstructor:(NSDateFormatter *(^)(void))block;

@end
