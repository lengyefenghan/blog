---
title: "Go 通过windows wmi获取系统信息"
date: 2021-04-21T08:56:32+08:00
draft: false
tags: ["wmi","golang"]

categories: ["golang"]
---

# wmi是什么
WMI，是Windows 2K/XP管理系统的核心；对于其他的Win32操作系统，WMI是一个有用的插件。WMI以CIMOM为基础，CIMOM即公共信息模型对象管理器（Common Information Model Object Manager），是一个描述操作系统构成单元的对象数据库，为MMC和脚本程序提供了一个访问操作系统构成单元的公共接口。有了WMI，工具软件和脚本程序访问操作系统的不同部分时不需要使用不同的API；相反，操作系统的不同部分都可以插入WMI，如图所示，工具软件和脚本程序可以方便地读写WMI。

# Go语言如何调用

``` Go Golang
package main

import (
	"github.com/StackExchange/wmi"
	"fmt"
    "log"
)
//根据文档定义的完整结构体
//https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor
type Win32_Processor struct {
	AddressWidth	uint16
	Architecture	uint16
	AssetTag	string
	Availability	uint16
	Caption	string
	Characteristics	uint32
	ConfigManagerErrorCode	uint32
	ConfigManagerUserConfig	bool
	CpuStatus	uint16
	CreationClassName	string
	CurrentClockSpeed	uint32
	CurrentVoltage	uint16
	DataWidth	uint16
	Description	string
	DeviceID	string
	ErrorCleared	bool
	ErrorDescription	string
	ExtClock	uint32
	Family	uint16
	InstallDate	time.Time
	L2CacheSize	uint32
	L2CacheSpeed	uint32
	L3CacheSize	uint32
	L3CacheSpeed	uint32
	LastErrorCode	uint32
	Level	uint16
	LoadPercentage	uint16
	Manufacturer	string
	MaxClockSpeed	uint32
	Name	string
	NumberOfCores	uint32
	NumberOfEnabledCore	uint32
	NumberOfLogicalProcessors	uint32
	OtherFamilyDescription	string
	PartNumber	string
	PNPDeviceID	string
	PowerManagementCapabilities[]	uint16
	PowerManagementSupported	bool
	ProcessorId	string
	ProcessorType	uint16
	Revision	uint16
	Role	string
	SecondLevelAddressTranslationExtensions	bool
	SerialNumber	string
	SocketDesignation	string
	Status	string
	StatusInfo	uint16
	Stepping	string
	SystemCreationClassName	string
	SystemName	string
	ThreadCount	uint32
	UniqueId	string
	UpgradeMethod	uint16
	Version	string
	VirtualizationFirmwareEnabled	bool
	VMMonitorModeExtensions	bool
	VoltageCaps	uint32
}
//通过wmi库获取类，返回给结构体
func GetWin32_Processor()[]Win32_Processor{
	var info []Win32_Processor
	err := wmi.Query("Select * from Win32_Processor",&info)
	if err == nil {
		return info
	}
	log.Println(err)
	return nil
}
//输出查询结果
func main(){
    fmt.Println(GetWin32_Processor())
}

```

# 接口文档位置

https://docs.microsoft.com/en-us/windows/win32/cimwin32prov/cimwin32-wmi-providers