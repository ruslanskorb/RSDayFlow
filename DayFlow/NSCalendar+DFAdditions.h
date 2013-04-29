#import <Foundation/Foundation.h>

@interface NSCalendar (DFAdditions)

- (NSDateFormatter *) df_dateFormatterNamed:(NSString *)name withConstructor:(NSDateFormatter *(^)(void))block;

@end
