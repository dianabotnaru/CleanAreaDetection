//
//  SGWebViewController.m
//  SmartGel
//
//  Created by jordi on 15/10/2017.
//  Copyright © 2017 AFCO. All rights reserved.
//

#import "SGWebViewController.h"

@interface SGWebViewController ()<UIWebViewDelegate>

@end

@implementation SGWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *urlString = @"http://www.thonhauser.net/en/products/hygiene-check/tm-smart-gel/";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.hud hideAnimated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.hud hideAnimated:YES];
    [self showAlertdialog:@"Load Failed!" message:@"Please check internet connection!"];
}

-(void)showAlertdialog:(NSString*)title message:(NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
