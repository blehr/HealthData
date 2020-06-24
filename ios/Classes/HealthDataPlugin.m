#import "HealthDataPlugin.h"
#if __has_include(<health_data/health_data-Swift.h>)
#import <health_data/health_data-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "health_data-Swift.h"
#endif

@implementation HealthDataPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHealthDataPlugin registerWithRegistrar:registrar];
}
@end
