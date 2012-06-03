package com.saifx.controls
{
	import com.saifx.controls.UITextFieldAdv;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.Label;
	import mx.core.UITextField;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	use namespace mx_internal;

	public class LabelAdv extends Label
	{
		public function LabelAdv()
		{
			super();
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
	    [Bindable(event="textHeightChanged")]
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
	    [Bindable(event="textWidthChanged")]
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
		        textField = UITextField(createInFontContext(UITextFieldAdv));
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
			_text = null;
	 		_htmlText = explicitHTMLText = value;
	 		super.htmlText = value;
	    }
	    
	    public override function set text(value:String):void
	    {
	        if (!value)
	            value = "";
	
	        if (!isHTML && value == _text)
	            return;

			_text = value;
			_htmlText = null;
			textChanged = true;
	    	explicitHTMLText = null;
	    	super.text = value;
	    }

	    private var _truncated:Boolean = false;
	    
	    [Bindable("truncatedChanged")]
	    public function get truncated():Boolean
	    {
	    	return(_truncated);
	    }
	    
	    protected var cachedHTMLInfoData:*;
	    protected var cachedHTMLInfoKey:String;
	    
	    public var cacheHTMLInfo:Boolean = false;

	  override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
      super.updateDisplayList( unscaledWidth, unscaledHeight );
      
      if ( truncateToFit )
      {
        var t:String = isHTML ? explicitHTMLText : text; 

        if ( isHTML )
        {
          var htmlInfo:*;

                  // Reset the text in case it was previously
                  // truncated with a "...".
                  textField.htmlText = _htmlText;
                  
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
                  
                  UITextFieldAdv( textField ).truncateToFitHTML( htmlInfo );
        }
      }
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
          dispatchEvent( new Event( "textWidthChanged" ) );
          dispatchEvent( new Event( "textHeightChanged" ) );
      }

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
  }
}
