/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class OstTheme {
    public static var fontProvider: OstFontProvider = OstFontProvider(fontName: "Lato");
    
    //Buttons
    public static var primaryButton: OstPrimaryButton = OstPrimaryButton();
    public static var secondaryButton: OstSecondaryButton = OstSecondaryButton();
    public static var linkButton: OstLinkButton = OstLinkButton();
    
    
    //Labels
    public static var h1:OstH1Theamer = OstH1Theamer();
    public static var leadLabel:OstLeadLabelTheamer = OstLeadLabelTheamer();
    
    //Navigation
    static var blueNavigation: OstBlueNavigation = OstBlueNavigation()    
}
