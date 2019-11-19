# OstWalletUI Custom Loader

Developer can add application loader instead of OstWalletSdk default loader while using OstWalletUI.

## Setup

#### 1. Create Loader Manager Object

```Swift
import OstWalletSdk

class LoaderManager: OstLoaderDelegate {

    func getLoader(workflowType: OstWorkflowType) -> OstWorkflowLoader {
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

Loader Controller should confirms `OstWorkflowLoader` protocol.

* onInitLoader: Delegate gets called when OstWalletUI is processing
* onPostAuthentication: OstWalletUI call this delegate after user enters pin
* onAcknowledge: Delegate gets called after request is submitted for confirmation
* onSuccess: This method gets called after confirmation.
* onFailure: After failure of confirmation, sdk calls onFailure

>**Note**<br/>
>Developer should call `dismissWorkflow` of `OstLoaderCompletionDelegate` to close Loader UI.<br/>
>Not calling delegate `dismissWorkflow` causes application freeze.

```Swift
import OstWalletSdk

class LoaderViewController: UIViewController, OstWorkflowLoader {

    var ostLoaderComplectionDelegate: OstLoaderCompletionDelegate? = nil
      
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
                   loaderComplectionDelegate: OstLoaderCompletionDelegate) {
    
        ostLoaderComplectionDelegate = loaderComplectionDelegate
    
        showSuccessAlert(workflowContext: workflowContext,
                         contextEntity: contextEntity)
    }

    func onFailure(workflowContext: OstWorkflowContext,
                   error: OstError,
                   workflowConfig: [String : Any],
                   loaderComplectionDelegate: OstLoaderCompletionDelegate) {
    
        ostLoaderComplectionDelegate = loaderComplectionDelegate
    
        showFailureAlert(workflowContext: workflowContext,
                         error: error)
    }
    
    func dismissLoader() {
        ostLoaderComplectionDelegate?.dismissWorkflow()
    }
}
```
