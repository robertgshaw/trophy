//
//  TAGroupInviteViewController.m
//  Trophy
//
//  Created by Gigster on 1/25/15.
//  Copyright (c) 2015 Gigster. All rights reserved.
//

#import "TAGroupInviteViewController.h"

#import "TAFriendContact.h"
#import "TAGroupInviteCell.h"

#import "UIColor+TAAdditions.h"
#include <AddressBook/AddressBook.h>
@import MessageUI;

static const NSInteger kMinCharsInPhoneNumber = 10;
static const CGFloat kMinContactsForScrubber = 20.0;

@interface TAGroupInviteViewController ()<UITableViewDataSource,
                                          UITableViewDelegate,
                                          TAGroupInviteCellDelegate,
                                          MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, assign) BOOL shouldShowScrubber;
@property (nonatomic, strong) NSArray *friendContactSections;

@end

@implementation TAGroupInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.textColor = [UIColor trophyYellowColor];
    titleLabel.text = @"Invite Friends";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    rightButton.tintColor = [UIColor standardBlueButtonColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    [self populateContacts];
}

- (void)recomputeTableViewSections
{
    self.shouldShowScrubber = NO;
    if ([self.friends count] > kMinContactsForScrubber) {
        self.shouldShowScrubber = YES;
    }
    self.friendContactSections = [self sectionsForContacts:self.friends];
    self.tableView.showsVerticalScrollIndicator = self.shouldShowScrubber;
}

- (void)doneButtonPressed
{
    [self.delegate groupInviteViewControllerDidPressDone:self];
}

#pragma mark - Import Contacts Method

- (void)populateContacts
{
    self.friends = nil;
    NSMutableArray *contacts = [NSMutableArray array];
    ABAddressBookRef addressBook = [self createAddressBook];
    if (addressBook) {
        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFMutableArrayRef peopleSorted = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                                   CFArrayGetCount(people),
                                                                   people);
        CFArraySortValues(peopleSorted,
                          CFRangeMake(0, CFArrayGetCount(peopleSorted)),
                          (CFComparatorFunction) ABPersonComparePeopleByName,
                          kABPersonSortByFirstName);
        CFRelease(people);
        for (CFIndex i = 0; i < CFArrayGetCount(peopleSorted); i++) {
            NSMutableDictionary *friendDict = [[NSMutableDictionary alloc] init];
            
            ABRecordRef person = CFArrayGetValueAtIndex(peopleSorted, i);
            NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
            ABPersonCompositeNameFormat nameFormat = ABPersonGetCompositeNameFormatForRecord(person);
            
            if ([firstName length] > 0) {
                [friendDict setValue:firstName forKey:@"firstName"];
            }
            if ([lastName length] > 0) {
                [friendDict setValue:lastName forKey:@"lastName"];
            }
            if ([firstName length] && [lastName length]) {
                NSString *fullName;
                if (nameFormat == kABPersonCompositeNameFormatFirstNameFirst) {
                    fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                } else {
                    fullName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
                }
                [friendDict setValue:fullName forKey:@"fullName"];
            }
            
            NSMutableArray *phoneLabels = [NSMutableArray array];
            NSMutableArray *phoneNumbers = [NSMutableArray array];
            ABMultiValueRef contactNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (CFIndex j = 0; j < ABMultiValueGetCount(contactNumbers); j++) {
                NSString* number = CFBridgingRelease(ABMultiValueCopyValueAtIndex(contactNumbers, j));
                NSString *phoneLabel = CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(contactNumbers, j)));
                
                if ([number length] < kMinCharsInPhoneNumber) {
                    continue;
                }
                
                if (phoneLabel) {
                    [phoneLabels addObject:phoneLabel];
                } else {
                    [phoneLabels addObject:@""];
                }
                [phoneNumbers addObject:number];
            }
            CFRelease(contactNumbers);
            
            NSString *fullName = friendDict[@"fullName"];
            if ([fullName length] > 0 && [phoneNumbers count] > 0) {
                [friendDict setValue:phoneNumbers forKey:@"phoneNumbers"];
                [friendDict setValue:phoneLabels forKey:@"phoneNumberLabels"];
                for (int i = 0; i < [phoneNumbers count]; i++) {
                    NSMutableDictionary *phoneContact = [friendDict mutableCopy];
                    phoneContact[@"phoneNumbers"] = @[phoneNumbers[i]];
                    phoneContact[@"phoneNumberLabels"] = @[phoneLabels[i]];
                    TAFriendContact *friend = [[TAFriendContact alloc] initWithDictionary:phoneContact];
                    [contacts addObject:friend];
                }
            }
        }
        CFRelease(addressBook);
        CFRelease(peopleSorted);
    }
    if (contacts) {
        self.friends = [contacts copy];
        [self recomputeTableViewSections];
        [self.tableView reloadData];
    }
}

- (ABAddressBookRef)createAddressBook
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);

    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
        __block bool accessGranted = false;
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        if (accessGranted == false) {
            CFRelease(addressBook);
            return NULL;
        }
    }
    return addressBook;
}

#pragma mark - UITableView Methods

- (NSArray *)sectionsForContacts:(NSArray *)contacts
{
    NSUInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger i = 0; i < sectionTitlesCount; i++) {
        [mutableSections addObject:[NSMutableArray array]];
    }
    
    for (TAFriendContact *friend in contacts) {
        NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:friend collationStringSelector:@selector(fullName)];
        [mutableSections[sectionNumber] addObject:friend];
    }
    
    for (NSUInteger i = 0; i < sectionTitlesCount; i++) {
        NSArray *objectsForSection = mutableSections[i];
        mutableSections[i] = [[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:objectsForSection collationStringSelector:@selector(fullName)];
    }
    return [mutableSections copy];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.shouldShowScrubber) {
        NSArray *sections = self.friendContactSections;
        return [sections[section] count];
    }
    return [self.friends count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.shouldShowScrubber) {
        return [self.friendContactSections count];
    }
    return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.shouldShowScrubber) {
        return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.shouldShowScrubber) {
        return [[UILocalizedIndexedCollation currentCollation] sectionTitles][section];
    }
    return nil;
}

- (TAFriendContact *)contactForIndexPath:(NSIndexPath *)indexPath
{
    if (self.shouldShowScrubber) {
        NSArray *sections = self.friendContactSections;
        NSArray *contactsArray = sections[indexPath.section];
        return contactsArray[indexPath.row];
    }
    
    return self.friends[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TAFriendContact *friend = [self contactForIndexPath:indexPath];
    TAGroupInviteCell *cell = [[TAGroupInviteCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([TAGroupInviteCell class])];
    if (friend) {
        cell.contact = friend;
        cell.delegate = self;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - TAGroupInviteCellDelegate Methods

- (void)groupInviteCellDidPressSend:(TAGroupInviteCell *)inviteCell
{
    if ([MFMessageComposeViewController canSendText] == NO) return;
    
    TAFriendContact *friend = inviteCell.contact;
    NSString *message = [NSString stringWithFormat:@"Hey %@, I just created the group \"%@\" on Trophy! Code to join: %@", friend.firstName, self.groupName, self.inviteCode];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    [self presentMessageViewController:messageController
                       withPhoneNumber:friend.phoneNumbers[0]
                               message:message];
}

- (void)presentMessageViewController:(MFMessageComposeViewController *)controller
                     withPhoneNumber:(NSString *)phoneNumber
                         message:(NSString *)message
{
    controller.body = message;
    controller.recipients = @[phoneNumber];
    controller.messageComposeDelegate = self;
    
    [self presentViewController:controller animated:YES completion:nil];
}

# pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultSent) {
        NSLog(@"Message sent!");
    }
    [self recomputeTableViewSections];
    [self.tableView reloadData];
}


@end
