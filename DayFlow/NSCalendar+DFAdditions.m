#import "NSCalendar+DFAdditions.h"

@implementation NSCalendar (DFAdditions)

- (NSDateFormatter *) df_dateFormatterNamed:(NSString *)name withConstructor:(NSDateFormatter *(^)(void))block {
	
	//	We can not use objc_setAssociatedObject() because it has no thread safety
	//	Modeled after http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html
	//	Intended for use where there are a myriad of date formatters keyed on a calendar
	
	NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
	NSDateFormatter *dateFormatter = threadDictionary[name];
	
	if (!dateFormatter) {
		dateFormatter = block();
		threadDictionary[name] = dateFormatter;
	}
	
	return dateFormatter;

}

@end
