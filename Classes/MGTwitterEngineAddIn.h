/*
 *  MGTwitterEngineAddIn.h
 *  Tweetero
 *
 *  Created by Sergey Shkrabak on 10/9/09.
 *  Copyright 2009 Codeminders. All rights reserved.
 *
 */

#import "MGTwitterEngine.h"

#ifndef API_FORMAT
    #if YAJL_AVAILABLE
        #define API_FORMAT @"json"
    #else
        #define API_FORMAT @"xml"
    #endif
#endif

#ifndef HTTP_POST_METHOD
    #define HTTP_POST_METHOD @"POST"
#endif
