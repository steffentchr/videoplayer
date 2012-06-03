package com.saifx.controls
{
  import flash.display.DisplayObject;
  import flash.events.Event;
  import flash.events.MouseEvent;
  import flash.events.TextEvent;
  
  import mx.controls.Text;
  import mx.controls.textClasses.TextRange;
  import mx.core.IUITextField;
  import mx.core.UITextField;
  import mx.core.mx_internal;
  import mx.events.FlexEvent;
  
  use namespace mx_internal;
  
  [Event(name="truncatedChanged", type="flash.events.Event")]

  public class TextAdv extends Text
  {
    public function TextAdv()
    {
      super();
      truncateToFit = true;
      addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteHandler);
          
      addEventListener( FlexEvent.CREATION_COMPLETE, onCreationComplete );
    }
    
    protected function onCreationComplete(pEvent:FlexEvent):void
    {
      selectable = false;
    }

    //----------------------------------
    //  textHeight
    //----------------------------------

    /**
     *  @private
     *  Storage for the textHeight property.
     */
    protected var _textHeight:Number;

    /**
     *  The height of the text.
     *
     *  <p>The value of the <code>textHeight</code> property is correct only
     *  after the component has been validated.
     *  If you set <code>text</code> and then immediately ask for the
     *  <code>textHeight</code>, you might receive an incorrect value.
     *  You should wait for the component to validate
     *  or call the <code>validateNow()</code> method before you get the value.
     *  This behavior differs from that of the flash.text.TextField control,
     *  which updates the value immediately.</p>
     *
     *  @see flash.text.TextField
     */
    override public function get textHeight():Number
    {
        return _textHeight;
    }

    //----------------------------------
    //  textWidth
    //----------------------------------

    /**
     *  @private
     *  Storage for the textWidth property.
     */
    protected var _textWidth:Number;

    /**
     *  The width of the text.
     *
     *  <p>The value of the <code>textWidth</code> property is correct only
     *  after the component has been validated.
     *  If you set <code>text</code> and then immediately ask for the
     *  <code>textWidth</code>, you might receive an incorrect value.
     *  You should wait for the component to validate
     *  or call the <code>validateNow()</code> method before you get the value.
     *  This behavior differs from that of the flash.text.TextField control,
     *  which updates the value immediately.</p>
     *
     *  @see flash.text.TextField
     */
    override public function get textWidth():Number
    {
        return _textWidth;
    }

    /**
     *  @private
     *  Creates the text field child and adds it as a child of this component.
     * 
     *  @param childIndex The index of where to add the child.
     *  If -1, the text field is appended to the end of the list.
     */
    override mx_internal function createTextField(childIndex:int):void
    {   
        if (!textField)
        {
            textField = IUITextField(createInFontContext(UITextFieldAdv));
            textField.enabled = enabled;
            textField.ignorePadding = true;
            textField.selectable = selectable;
            textField.styleName = this;
            textField.addEventListener("textFieldStyleChange",
                                       textField_textFieldStyleChangeHandler);
            textField.addEventListener("textInsert",
                                       textField_textModifiedHandler);                                       
            textField.addEventListener("textReplace",
                                       textField_textModifiedHandler);                                       
                                       
            if (childIndex == -1)
                addChild(DisplayObject(textField));
            else
                addChildAt(DisplayObject(textField), childIndex);
        }
    }
    
      protected var explicitHTMLText:String = null; 
      protected var _htmlText:String = "";
      protected var _text:String = "";
      protected var textChanged:Boolean = false;
      protected var htmlTextChanged:Boolean = false;
    
      [Bindable("htmlTextChanged")]
      [CollapseWhiteSpace]
      [Inspectable(category="General", defaultValue="")]
      public override function get htmlText():String
      {
          return _htmlText;
      }
  
      /**
       *  @private
       */
      public override function set htmlText(value:String):void
      {
        if (!value)
            value = "";

        if (isHTML && value == explicitHTMLText)
            return;

        _truncated = false;
        dispatchEvent(new Event("truncatedChanged"));

        htmlTextChanged = true;
        _htmlText = explicitHTMLText = value;
        super.htmlText = value;
      }
      
      public override function set text(value:String):void
      {
        if (!value)
            value = "";

        if (!isHTML && value == _text)
            return;

        textChanged = true;
        explicitHTMLText = null;
        _text = value;
        super.text = value;
      }

      private var _truncated:Boolean = false;
      
      [Bindable("truncatedChanged")]
      public function get truncated():Boolean
      {
        return(_truncated);
      }

      /**
       *  @private
       */
      protected function get isHTML():Boolean
      {
          return explicitHTMLText != null;
      }

      /**
       *  @private
       *  Setting the 'htmlText' of textField changes its 'text',
       *  and vice versa, so afterwards doing so we call this method
       *  to update the storage vars for various properties.
       *  Afterwards, the Label's 'text', 'htmlText', 'textWidth',
       *  and 'textHeight' are all in sync with each other
       *  and are identical to the TextField's.
       */
      protected function textFieldChanged(styleChangeOnly:Boolean):void
      {
          var changed1:Boolean;
          var changed2:Boolean;
  
          if (!styleChangeOnly)
          {
              changed1 = _text != textField.text;
              _text = textField.text;
          }
  
          changed2 = _htmlText != textField.htmlText;
          _htmlText = textField.htmlText;
  
          // If the 'text' property changes, dispatch a valueCommit
          // event, which will trigger bindings to 'text'.
          if (changed1)
              dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
          // If the 'htmlText' property changes, trigger bindings to it.
          if (changed2)
              dispatchEvent(new Event("htmlTextChanged"));
  
          _textWidth = textField.textWidth;
          _textHeight = textField.textHeight;
      }

      //--------------------------------------------------------------------------
      //
      //  Variables
      //
      //--------------------------------------------------------------------------
  
      /**
       *  @private
       */
      protected var lastUnscaledWidth:Number = NaN;

      //--------------------------------------------------------------------------
      //
      //  Event handlers
      //
      //--------------------------------------------------------------------------
  
      /**
       *  @private
       */
      protected function textField_textFieldStyleChangeHandler(event:Event):void
      {
          textFieldChanged(true);
      }
  
      /**
       *  @private
       */
      protected function textField_textModifiedHandler(event:Event):void
      {
          textFieldChanged(false);
      }

      /**
       *  @private
       */
      protected function updateCompleteHandler(event:FlexEvent):void
      {
          lastUnscaledWidth = NaN;
      }

      /**
       *  @private
       *
       *  If the Text component has an explicit width,
       *  its text wordwraps within that width,
       *  and the measured height is tall enough to display all the text.
       *  (If there is an explicit height or a percent height in this case,
       *  the text may get clipped.)
       *
       *  If it doesn't have an explicit height,
       *  the measured height is tall enough to display all the text.
       *  If there is an explicit height or a percent height,
       *  the text may get clipped.
       *
       *  If the Text doesn't have an explicit width,
       *  the measured width is based on explicit line breaks
       *  (e.g, \n, &lt;br&gt;, etc.).
       *  For example, if the text is
       *
       *      The question of the day is:
       *      What is the right algorithm for Text?
       *
       *  with a line break between the two lines, then the measured width
       *  will be wide enough to see all of the second line,
       *  and the measured height will be tall enough for two lines.
       *
       *  For lengthy text without explicit line breaks,
       *  this will produce unusably wide layout.
       */
      override protected function measure():void
      {
          if (isSpecialCase())
          {
              if (!isNaN(lastUnscaledWidth))
              {
                  measureUsingWidth(lastUnscaledWidth);
              }
              else
              {
                  // We're not ready to measure yet.
                  // We need updateDisplayList() to first tell us the unscaledWidth
                  // that has been calculated from the percentWidth.
                  measuredWidth = 0;
                  measuredHeight = 0;
              }
              return;
          }
  
          measureUsingWidth(explicitWidth);
          
      }

      /**
       *  @private
       *  The cases that requires a second pass through the LayoutManager
       *  are <mx:Text width="N%"/> (the control is to use the percentWidth
       *  but the measuredHeight) and <mx:Text left="N" right="N"/>
       *  (the control is to use the parent's width minus the constraints
       *  but the measuredHeight).
       */
      protected function isSpecialCase():Boolean
      {
          var left:Number = getStyle("left");
          var right:Number = getStyle("right");
          
          return (!isNaN(percentWidth) || (!isNaN(left) && !isNaN(right))) &&
                 isNaN(explicitHeight) &&
                 isNaN(percentHeight);
      }

      /**
       *  @private
       */
      protected function measureUsingWidth(w:Number):void
      {
          /*
          var t:String = isHTML ? explicitHTMLText : text; 
  
          // If the text is null, empty, or a single character,
          // make the measured size big enough to hold
          // a capital and decending character using the current font.
          if (!t || t.length < 2)
              t = "Wj";
          */
  
          // Don't call super.measure();
          // Text has a different measurement algorithm than Label.
  
          var paddingLeft:Number = getStyle("paddingLeft");
          var paddingTop:Number = getStyle("paddingTop");
          var paddingRight:Number = getStyle("paddingRight");
          var paddingBottom:Number = getStyle("paddingBottom");
          
          var preText:String 
          if ( isHTML )
          {
            preText = textField.htmlText;
            textField.htmlText = _htmlText;
          }
          else
          {
            preText = textField.text;
            textField.text = _text;
          }
          
          
          // Ensure that the proper CSS styles get applied
          // to the textField before measuring text.
          // Otherwise the callLater(validateNow) in UITextField's
          // styleChanged() method can apply the CSS styles too late.
          textField.validateNow();
          
          textField.autoSize = "left";
  
          // If we know what width to use for word wrapping,
          // determine the height by wordwrapping to that width.
          if (!isNaN(w))
          {
              textField.width = w - paddingLeft - paddingRight;
  
              measuredWidth = Math.ceil(textField.textWidth) + UITextField.TEXT_WIDTH_PADDING;
              measuredHeight = Math.ceil(textField.textHeight) + UITextField.TEXT_HEIGHT_PADDING;
              // Round up because embedded fonts can produce fractional values;
              // if a parent container rounds a component's actual width or height
              // down, the component may not be wide enough to display the text.
          }
  
          // If we don't know what width to use for word wrapping,
          // determine the measured width and height
          // from the explicit line breaks such as "\n" and "<br>".
          else
          {
            var oldWordWrap:Boolean = textField.wordWrap;
              textField.wordWrap = false;
              
              measuredWidth = Math.ceil(textField.textWidth) + UITextField.TEXT_WIDTH_PADDING;
              measuredHeight = Math.ceil(textField.textHeight) + UITextField.TEXT_HEIGHT_PADDING;
              // Round up because embedded fonts can produce fractional values;
              // if a parent container rounds a component's actual width or height
              // down, the component may not be wide enough to display the text.
              
              textField.wordWrap = oldWordWrap;
          }
          
          textField.autoSize = "none";
  
          // Add in the padding.
          measuredWidth += paddingLeft + paddingRight;
          measuredHeight += paddingTop + paddingBottom;
  
          if (isNaN(explicitWidth))
          {
              // it could be any size
              measuredMinWidth = DEFAULT_MEASURED_MIN_WIDTH;
              measuredMinHeight = DEFAULT_MEASURED_MIN_HEIGHT;
          }
          else
          {
              // lock in the content area
              measuredMinWidth = measuredWidth;
              measuredMinHeight = measuredHeight;
          }
  
          if ( isHTML )
            textField.htmlText = preText;
          else
            textField.text = preText;
          
          textField.validateNow();
      }

      protected var cachedHTMLInfoData:*;
      protected var cachedHTMLInfoKey:String;
      
      public var cacheHTMLInfo:Boolean = false;

    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
      if ( truncateToFit )
      {
        var t:String = isHTML ? explicitHTMLText : text; 

        var truncated:Boolean = false;

        if ( isHTML )
        {
                  // Reset the text in case it was previously
                  // truncated with a "...".
                  textField.htmlText = _htmlText;
                  
          if ( height > 2 )
          {
            var htmlInfo:*;

            if ( cacheHTMLInfo )
            {
                      if ( cachedHTMLInfoKey != textField.htmlText )
                      {
                        cachedHTMLInfoKey = textField.htmlText;
                        cachedHTMLInfoData = UITextFieldAdv.parseHTML( cachedHTMLInfoKey );
                      }
                      htmlInfo = cachedHTMLInfoData;
               }
               else
               {
                 htmlInfo = UITextFieldAdv.parseHTML( textField.htmlText );
               }
                    
                    truncated = UITextFieldAdv( textField ).truncateToFitHeightHTML( width, height, htmlInfo );
             }
        }
        else
        {
          textField.text = _text;

          if ( height > 2 )
          {
            truncated = UITextFieldAdv( textField ).truncateToFitHeight( width, height );
          }
        }
        
        if ( truncated != _truncated )
        {
          _truncated = truncated;
          dispatchEvent( new Event( "truncatedChanged" ) );
        }

            // Don't call super.updateDisplayList();
            // Text has a different layout algorithm than Label.
            if (isSpecialCase())
            {
                var firstTime:Boolean = isNaN(lastUnscaledWidth) || lastUnscaledWidth != unscaledWidth;
                lastUnscaledWidth = unscaledWidth;
                if (firstTime)
                {
                    invalidateSize();
                    return;
                }
            }
    
            // The textField occupies the entire Text bounds minus the padding.
            var paddingLeft:Number = getStyle("paddingLeft");
            var paddingTop:Number = getStyle("paddingTop");
            var paddingRight:Number = getStyle("paddingRight");
            var paddingBottom:Number = getStyle("paddingBottom");
            textField.setActualSize(unscaledWidth - paddingLeft - paddingRight,
                                    unscaledHeight - paddingTop - paddingBottom);
    
            textField.x = paddingLeft;
            textField.y = paddingTop;
            // Although we also set wordWrap in commitProperties(), we do 
            // this here to handle width being set through setActualSize().
            if (Math.floor(width) < Math.floor(measuredWidth))
          textField.wordWrap =  true;
        }
    }
    
    override public function set selectable(pSelectable:Boolean):void
    {
      super.selectable = pSelectable;
      if (textField)
      {
        textField.selectable = pSelectable;
      }
      else
      {
        // If we're attempting to set selectable before the component
        // has completed its instantiation, we need to postpone
        // passing the command on to the textField (which won't have
        // been created yet) until instantiation has completed.
        callLater(function(pSelectable:Boolean):void
        {
          textField.selectable = pSelectable;
        }, [pSelectable]);
      }
      if (!pSelectable)
      {
        addEventListener(MouseEvent.CLICK, onClick);
      }
      else
      {
        if( textField )
        {
          UITextField(textField).setSelection(-1, -1);
        }
        removeEventListener(MouseEvent.CLICK, onClick);
      }
    }
    
    protected function onClick(pEvent:MouseEvent):void
    {
      // Find the letter under our click
      var index:int = textField.getCharIndexAtPoint(pEvent.localX, pEvent.localY);
      if (index != -1)
      {
        // convert the letter to a text range so we can extract the url
        var range:TextRange = new TextRange(this, false, index, index + 1);
        // make sure it contains a url
        if (range.url.length > 0)
        {
          // The normal click event strips out the 'event;' portion of the url.
          // So to be consistent, let's strip it out, too.
          var url:String = range.url;
          if (url.substr(0, 6) == 'event:')
          {
            url = url.substring(6);
          }
          // Manually dispatch the link event with the url neatly included
          dispatchEvent(new TextEvent(TextEvent.LINK, false, false, url));
        }
      }
    }
  }
}
