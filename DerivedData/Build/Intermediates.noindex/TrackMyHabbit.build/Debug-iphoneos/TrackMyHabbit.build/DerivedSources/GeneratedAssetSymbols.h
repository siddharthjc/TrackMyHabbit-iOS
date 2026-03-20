#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "EmptyStateHero" asset catalog image resource.
static NSString * const ACImageNameEmptyStateHero AC_SWIFT_PRIVATE = @"EmptyStateHero";

#undef AC_SWIFT_PRIVATE
