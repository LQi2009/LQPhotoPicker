//
//  LQAlbumConfig.swift
//  LQAlbumFinder
//
//  Created by LiuQiqiang on 2018/8/17.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit

//#define IS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)

//let LQAlbumWindowWidth = UIScreen.main.bounds.width
//let LQAlbumWindowHeight = UIScreen.main.bounds.height
let LQAlbumWindowScale = UIScreen.main.scale
let LQAlbum_iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)



// 图片名称
let LQPhotoIcon_bundle = "LQAlbumSources.bundle/"

let LQPhotoIcon_itemUnSelected = LQPhotoIcon_bundle + "rb_unSelected"
let LQPhotoIcon_itemSelected =  LQPhotoIcon_bundle + "rb_selected"

let LQPhotoIcon_originalSelected = LQPhotoIcon_bundle + "rb_origin_selected"
let LQPhotoIcon_originalUnSelected = LQPhotoIcon_bundle + "rb_origin_unSelected"

let LQPhotoIcon_back = LQPhotoIcon_bundle + "rb_back"
let LQPhotoIcon_cancel = LQPhotoIcon_bundle + "rb_cancel"
let LQPhotoIcon_commitButtonBg = LQPhotoIcon_bundle + "GreenBtnHighlight"

let LQPhotoIcon_camera = LQPhotoIcon_bundle + "rb_camera"

let LQPhotoIcon_video_play = LQPhotoIcon_bundle + "rb_video_play"
let LQPhotoIcon_video_pause = LQPhotoIcon_bundle + "rb_video_pause"
