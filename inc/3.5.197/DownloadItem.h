//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class NSDate, NSMutableArray, NSMutableData, NSOperationQueue, NSString, NSURLConnection, NSXMLParser;

@interface DownloadItem : NSObject
{
    DownloadItem *_parent;
    NSString *_pageUrl;
    NSString *_url;
    NSString *_title;
    NSString *_parentTitle;
    unsigned long long _lengthSeconds;
    NSString *_thumbnailUrl;
    unsigned long long _itag;
    NSString *_mimeType;
    NSString *_format;
    unsigned long long _resolution;
    unsigned long long _fps;
    NSString *_sig;
    NSMutableArray *_videoResources;
    int _currentState;
    NSString *_downloadDir;
    NSString *_pathToPackageOfDownload;
    NSURLConnection *_connectForGetSize;
    unsigned long long _summaryVideoDataLength;
    unsigned long long _summarySoundDataLength;
    unsigned long long _summaryAudioDataLength;
    unsigned long long _totalExpectedBytes;
    unsigned long long _totalReceivedBytes;
    unsigned long long _expectedBytes;
    unsigned long long _receivedBytes;
    unsigned long long _bytesForUpdate;
    NSURLConnection *_connectForDownloadVideo;
    NSURLConnection *_connectForDownloadSound;
    NSDate *_startDownload;
    unsigned long long _totalReceivedBytesSound;
    unsigned long long _expectedBytesSound;
    unsigned long long _receivedBytesSound;
    NSString *_urlSoundItem;
    unsigned long long _totalExpectedBytesOfSound;
    NSString *_pathToFileDashVideo;
    NSString *_pathToFileDashSound;
    NSString *_pathToTheSavedVideo;
    NSString *_pathTemporaryFolder;
    NSURLConnection *_connectForDownloadMP3;
    NSString *_pathToFileDashAudio;
    NSString *_pathToTheSavedAudio;
    NSString *_pathToFileWithCover;
    NSString *_coverImage;
    NSMutableArray *_urlOfSegments;
    NSMutableArray *_urlOfSoundSegments;
    long long _numOfSegment;
    long long _numOfSoundSegment;
    NSURLConnection *_connectForDownloadSegment;
    NSURLConnection *_connectForDownloadSoundSegment;
    NSOperationQueue *_queueOfSavingVideoSegments;
    NSOperationQueue *_queueOfSavingSoundSegments;
    NSOperationQueue *_queueOfSavingAudioSegments;
    NSURLConnection *_connectGetInfoSubTrack;
    NSXMLParser *_xmlParser;
    NSMutableData *_dataSubTrack;
    BOOL _captureTrackInfo;
    NSMutableArray *_subtitleTracks;
    NSString *_folderOfVideoWithSub;
    BOOL _deviceWasDeleted;
    BOOL _videoFileWasDeleted;
    BOOL _audioFileWasDeleted;
    BOOL _wasSavedVideo;
    BOOL _wasSavedSound;
    NSOperationQueue *_queueOfSavingVideo;
    NSOperationQueue *_queueOfSavingSound;
    NSOperationQueue *_queueOfSavingMp3;
    double _percentageConvertion;
    BOOL _needAllocMemForSavedUpVideoData;
    BOOL _needAllocMemForSavedUpSoundData;
    BOOL _needAllocMemForSavedUpMp3Data;
    NSMutableData *_savedUpVideoData;
    NSMutableData *_savedUpSoundData;
    NSMutableData *_savedUpMp3Data;
    double _multiplier;
    BOOL _updatingLink;
    BOOL _updateError;
    BOOL _livePlayback;
}

+ (id)downloadItemFromDictionaryRepresentation:(id)arg1;
@property(nonatomic) BOOL livePlayback; // @synthesize livePlayback=_livePlayback;
@property(nonatomic) BOOL updateError; // @synthesize updateError=_updateError;
@property(nonatomic) BOOL updatingLink; // @synthesize updatingLink=_updatingLink;
@property(nonatomic) double multiplier; // @synthesize multiplier=_multiplier;
@property(retain, nonatomic) NSMutableData *savedUpMp3Data; // @synthesize savedUpMp3Data=_savedUpMp3Data;
@property(retain, nonatomic) NSMutableData *savedUpSoundData; // @synthesize savedUpSoundData=_savedUpSoundData;
@property(retain, nonatomic) NSMutableData *savedUpVideoData; // @synthesize savedUpVideoData=_savedUpVideoData;
@property(nonatomic) BOOL needAllocMemForSavedUpMp3Data; // @synthesize needAllocMemForSavedUpMp3Data=_needAllocMemForSavedUpMp3Data;
@property(nonatomic) BOOL needAllocMemForSavedUpSoundData; // @synthesize needAllocMemForSavedUpSoundData=_needAllocMemForSavedUpSoundData;
@property(nonatomic) BOOL needAllocMemForSavedUpVideoData; // @synthesize needAllocMemForSavedUpVideoData=_needAllocMemForSavedUpVideoData;
@property(nonatomic) double percentageConvertion; // @synthesize percentageConvertion=_percentageConvertion;
@property(retain, nonatomic) NSOperationQueue *queueOfSavingMp3; // @synthesize queueOfSavingMp3=_queueOfSavingMp3;
@property(retain, nonatomic) NSOperationQueue *queueOfSavingSound; // @synthesize queueOfSavingSound=_queueOfSavingSound;
@property(retain, nonatomic) NSOperationQueue *queueOfSavingVideo; // @synthesize queueOfSavingVideo=_queueOfSavingVideo;
@property(nonatomic) BOOL wasSavedSound; // @synthesize wasSavedSound=_wasSavedSound;
@property(nonatomic) BOOL wasSavedVideo; // @synthesize wasSavedVideo=_wasSavedVideo;
@property(nonatomic) BOOL audioFileWasDeleted; // @synthesize audioFileWasDeleted=_audioFileWasDeleted;
@property(nonatomic) BOOL videoFileWasDeleted; // @synthesize videoFileWasDeleted=_videoFileWasDeleted;
@property(nonatomic) BOOL deviceWasDeleted; // @synthesize deviceWasDeleted=_deviceWasDeleted;
@property(retain, nonatomic) NSString *folderOfVideoWithSub; // @synthesize folderOfVideoWithSub=_folderOfVideoWithSub;
@property(retain, nonatomic) NSMutableArray *subtitleTracks; // @synthesize subtitleTracks=_subtitleTracks;
@property(nonatomic) BOOL captureTrackInfo; // @synthesize captureTrackInfo=_captureTrackInfo;
@property(retain, nonatomic) NSMutableData *dataSubTrack; // @synthesize dataSubTrack=_dataSubTrack;
@property(retain, nonatomic) NSXMLParser *xmlParser; // @synthesize xmlParser=_xmlParser;
@property(retain, nonatomic) NSURLConnection *connectGetInfoSubTrack; // @synthesize connectGetInfoSubTrack=_connectGetInfoSubTrack;
@property(retain, nonatomic) NSOperationQueue *queueOfSavingAudioSegments; // @synthesize queueOfSavingAudioSegments=_queueOfSavingAudioSegments;
@property(retain, nonatomic) NSOperationQueue *queueOfSavingSoundSegments; // @synthesize queueOfSavingSoundSegments=_queueOfSavingSoundSegments;
@property(retain, nonatomic) NSOperationQueue *queueOfSavingVideoSegments; // @synthesize queueOfSavingVideoSegments=_queueOfSavingVideoSegments;
@property(retain, nonatomic) NSURLConnection *connectForDownloadSoundSegment; // @synthesize connectForDownloadSoundSegment=_connectForDownloadSoundSegment;
@property(retain, nonatomic) NSURLConnection *connectForDownloadSegment; // @synthesize connectForDownloadSegment=_connectForDownloadSegment;
@property(nonatomic) long long numOfSoundSegment; // @synthesize numOfSoundSegment=_numOfSoundSegment;
@property(nonatomic) long long numOfSegment; // @synthesize numOfSegment=_numOfSegment;
@property(retain, nonatomic) NSMutableArray *urlOfSoundSegments; // @synthesize urlOfSoundSegments=_urlOfSoundSegments;
@property(retain, nonatomic) NSMutableArray *urlOfSegments; // @synthesize urlOfSegments=_urlOfSegments;
@property(retain, nonatomic) NSString *coverImage; // @synthesize coverImage=_coverImage;
@property(retain, nonatomic) NSString *pathToFileWithCover; // @synthesize pathToFileWithCover=_pathToFileWithCover;
@property(retain, nonatomic) NSString *pathToTheSavedAudio; // @synthesize pathToTheSavedAudio=_pathToTheSavedAudio;
@property(retain, nonatomic) NSString *pathToFileDashAudio; // @synthesize pathToFileDashAudio=_pathToFileDashAudio;
@property(retain, nonatomic) NSURLConnection *connectForDownloadMP3; // @synthesize connectForDownloadMP3=_connectForDownloadMP3;
@property(retain, nonatomic) NSString *pathToFileDashSound; // @synthesize pathToFileDashSound=_pathToFileDashSound;
@property(retain, nonatomic) NSString *pathToFileDashVideo; // @synthesize pathToFileDashVideo=_pathToFileDashVideo;
@property(retain, nonatomic) NSString *pathToTheSavedVideo; // @synthesize pathToTheSavedVideo=_pathToTheSavedVideo;
@property(retain, nonatomic) NSString *pathTemporaryFolder; // @synthesize pathTemporaryFolder=_pathTemporaryFolder;
@property(nonatomic) unsigned long long totalExpectedBytesOfSound; // @synthesize totalExpectedBytesOfSound=_totalExpectedBytesOfSound;
@property(retain, nonatomic) NSString *urlSoundItem; // @synthesize urlSoundItem=_urlSoundItem;
@property(nonatomic) unsigned long long receivedBytesSound; // @synthesize receivedBytesSound=_receivedBytesSound;
@property(nonatomic) unsigned long long expectedBytesSound; // @synthesize expectedBytesSound=_expectedBytesSound;
@property(nonatomic) unsigned long long totalReceivedBytesSound; // @synthesize totalReceivedBytesSound=_totalReceivedBytesSound;
@property(retain, nonatomic) NSDate *startDownload; // @synthesize startDownload=_startDownload;
@property(retain, nonatomic) NSURLConnection *connectForDownloadSound; // @synthesize connectForDownloadSound=_connectForDownloadSound;
@property(retain, nonatomic) NSURLConnection *connectForDownloadVideo; // @synthesize connectForDownloadVideo=_connectForDownloadVideo;
@property(retain, nonatomic) NSURLConnection *connectForGetSize; // @synthesize connectForGetSize=_connectForGetSize;
@property(retain, nonatomic) NSString *pathToPackageOfDownload; // @synthesize pathToPackageOfDownload=_pathToPackageOfDownload;
@property(retain, nonatomic) NSString *downloadDir; // @synthesize downloadDir=_downloadDir;
@property(nonatomic) unsigned long long bytesForUpdate; // @synthesize bytesForUpdate=_bytesForUpdate;
@property(nonatomic) unsigned long long receivedBytes; // @synthesize receivedBytes=_receivedBytes;
@property(nonatomic) unsigned long long expectedBytes; // @synthesize expectedBytes=_expectedBytes;
@property(nonatomic) unsigned long long totalReceivedBytes; // @synthesize totalReceivedBytes=_totalReceivedBytes;
@property(nonatomic) unsigned long long totalExpectedBytes; // @synthesize totalExpectedBytes=_totalExpectedBytes;
@property(nonatomic) unsigned long long summaryAudioDataLength; // @synthesize summaryAudioDataLength=_summaryAudioDataLength;
@property(nonatomic) unsigned long long summarySoundDataLength; // @synthesize summarySoundDataLength=_summarySoundDataLength;
@property(nonatomic) unsigned long long summaryVideoDataLength; // @synthesize summaryVideoDataLength=_summaryVideoDataLength;
@property(nonatomic) int currentState; // @synthesize currentState=_currentState;
@property(retain, nonatomic) NSMutableArray *videoResources; // @synthesize videoResources=_videoResources;
@property(retain, nonatomic) NSString *sig; // @synthesize sig=_sig;
@property(nonatomic) unsigned long long fps; // @synthesize fps=_fps;
@property(nonatomic) unsigned long long resolution; // @synthesize resolution=_resolution;
@property(retain, nonatomic) NSString *format; // @synthesize format=_format;
@property(retain, nonatomic) NSString *mimeType; // @synthesize mimeType=_mimeType;
@property(nonatomic) unsigned long long itag; // @synthesize itag=_itag;
@property(retain, nonatomic) NSString *thumbnailUrl; // @synthesize thumbnailUrl=_thumbnailUrl;
@property(nonatomic) unsigned long long lengthSeconds; // @synthesize lengthSeconds=_lengthSeconds;
@property(retain, nonatomic) NSString *parentTitle; // @synthesize parentTitle=_parentTitle;
@property(retain, nonatomic) NSString *title; // @synthesize title=_title;
@property(retain, nonatomic) NSString *url; // @synthesize url=_url;
@property(retain, nonatomic) NSString *pageUrl; // @synthesize pageUrl=_pageUrl;
@property(retain, nonatomic) DownloadItem *parent; // @synthesize parent=_parent;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)initWithDictionaryRepresentation:(id)arg1;
- (id)dictionaryRepresentation;
- (BOOL)expiryDateOfLinkEnded:(id)arg1;
- (double)calculateMultiplier;
- (id)getItemWithFormat:(id)arg1 resolution:(long long)arg2 fps:(long long)arg3;
- (id)getItemWithMaxResolution;
- (id)getSoundItem;
- (id)getMp3Item;
- (id)getPageUrl;
- (BOOL)isReasonableFormat;
- (BOOL)isVideoDashMpd;
- (BOOL)isSoundDASH;
- (BOOL)isVideoDASH;
- (void)dealloc;
- (id)init;

@end
