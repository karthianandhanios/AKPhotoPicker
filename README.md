# AKPhotoPicker

## What is it?

AKPhotoPicker is basially a multi-image picker and previewer. Using this library you can able to select 10 number of images from your iPhone galary or camara. And also you can preview and edit(delete or add more) the list in the previewer screen itself. After that when you hit the send button you will get the callback with all the selected image data and close button for cancel the selection. 

## I came here because I want to ...

Past few months I was searching for the image Picker with mulit select option like whatsapp in the cocopods, I could not found one. So I thought to create a open source for it.

## Usage

Initialise the AkPhotoPicker with the viewcontroller where you need to present, type is camara or photo like from where you want to pick and the delegate to get the callback after selection is done or canceled

A simple code configuration for the integration
```sh
var picker  = AkPhotoPicker.init(type: type, viewController: self.navigationController!, delegate: self)
picker?.showPicker()

And confirm the FCAddAttachementHandlerDelegate delegate to get the callbacks

extension ClientViewController : FCAddAttachementHandlerDelegate {
    func selectedImageInfo(properties: [AttachmentProperties]) {
        print("selected image info", properties)
    }
    
    func cancelSendAttachemnts() {
         print("cancelSendAttachemnts")
    }
}
```
To understand more detail about the integration part please refer this example [AKPhotoPickerExample]

## Installation

AKPhotoPicker doesn't contain any external dependencies.

### CocoaPods

# Podfile

Add the below code snipet in your pod file

```sh
use_frameworks!
target 'YOUR_TARGET_NAME' do
    pod 'AKPhotoPicker'
end
```
Replace YOUR_TARGET_NAME and then, in the Podfile directory, type:
```sh
$ pod install
```
### Todos

- Configurable UI visual design and maximum number of image selection (for now max is 10)
- Simultaniously selecting images from camara and galary

License
----

[MIT]

[AKPhotoPickerExample]: <https://github.com/karthianandhanios/AKPhotoPicker/tree/master/AKPhotoPickerExample>
[MIT]: <https://github.com/karthianandhanios/AKPhotoPicker/blob/master/LICENSE>
