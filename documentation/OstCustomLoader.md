# OstWalletUI Custom Loader

A developer can add an application loader instead of the OstWalletSdk default loader while using OstWalletUI.

## Setup

#### 1. Create Loader Manager Object

OstWalletSdk uses `default loader` if developer returns `nil` from `getLoader`.

```Swift
import OstWalletSdk

class LoaderManager: OstLoaderDelegate {

  func getLoader(workflowType: OstWorkflowType) -> OstWorkflowLoader? {
    //Returns view controller of application loader, confirms `OstWorkflowLoader` protocol
  }
   
  func waitForFinalization(workflowType: OstWorkflowType) -> Bool {
    //Returns boolean flag, which determine whether loader should be shown till workflow completion. 
  }
}
```
#### 2. Set Loader Manager Object

```Swift
let loaderManagerObj = LoaderManager()
OstWalletUI.setLoaderManager(loaderManagerObj)
```
> **Caution**<br/>
>Loader manager object could be the plan `swift` class. OstWalletUI holds reference of it.<br/>
>Setting OstLoaderDelegate to view controller may cause memory leak.

#### 3. Create View Controller Application Loader

Loader Controller should confirm `OstWorkflowLoader` protocol.

* onInitLoader: Delegate gets called when OstWalletUI is processing
* onPostAuthentication: OstWalletUI call this delegate after a user enters the pin
* onAcknowledge: Delegate gets called after a request is submitted for confirmation
* onSuccess: This method gets called after confirmation.
* onFailure: After the failure of confirmation, SDK calls onFailure

>**Note**<br/>
>Developer should call `dismissWorkflow` of `OstLoaderCompletionDelegate` to close Loader UI.<br/>
>Not calling delegate `dismissWorkflow` causes application freeze.

```Swift
import OstWalletSdk

class LoaderViewController: UIViewController, OstWorkflowLoader {

  var ostLoaderCompletionDelegate: OstLoaderCompletionDelegate? = nil
    
  //MARK: - OstWorkflowLoader
  func onInitLoader(workflowConfig: [String: Any]) {
    var loaderString: String = "Initializing..."
   
    if let initLoaderData = workflowConfig["initial_loader"] as? [String: String],
      let text = initLoaderData["text"] {
       
      loaderString = text
    }
    //Set loader text(loaderString)
  }

  func onPostAuthentication(workflowConfig: [String: Any]) {
    var loaderString: String = "Processing..."
   
    if let initLoaderData = workflowConfig["loader"] as? [String: String],
      let text = initLoaderData["text"] {
       
      loaderString = text
    }  
    //Set loader text(loaderString)
  }

  func onAcknowledge(workflowConfig: [String: Any]) {
    var loaderString: String = "Waiting for confirmation..."
     
    if let initLoaderData = workflowConfig["acknowledge"] as? [String: String],
      let text = initLoaderData["text"] {
       
      loaderString = text
    } 
    //Set loader text(loaderString)
  }

  func onSuccess(workflowContext: OstWorkflowContext,
          contextEntity: OstContextEntity,
          workflowConfig: [String : Any],
          loaderCompletionDelegate: OstLoaderCompletionDelegate) {
   
    ostLoaderCompletionDelegate = loaderCompletionDelegate
   
    showSuccessAlert(workflowContext: workflowContext,
             contextEntity: contextEntity)
  }

  func onFailure(workflowContext: OstWorkflowContext,
          error: OstError,
          workflowConfig: [String : Any],
          loaderCompletionDelegate: OstLoaderCompletionDelegate) {
   
    ostLoaderCompletionDelegate = loaderCompletionDelegate
   
    showFailureAlert(workflowContext: workflowContext,
             error: error)
  }
   
  func dismissLoader() {
    ostLoaderCompletionDelegate?.dismissWorkflow()
  }
}
```
