//
//  STACommon.h
//  STAControls
//
//  Created by Aaron Jubbal on 2/26/15.
//  Copyright (c) 2015 Aaron Jubbal. All rights reserved.
//

#define STACONTROLS_DEBUG 1

#if STACONTROLS_DEBUG
#define STALog(fmt, ...) NSLog((@"[STAControls] " fmt), ##__VA_ARGS__)
#else
#define STALog(...)
#endif
