package com.saifx.controls
{
	import flash.text.TextLineMetrics;
	
	import mx.core.UITextField;
	import mx.core.mx_internal;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	use namespace mx_internal;

	public class UITextFieldAdv extends UITextField
	{
		public function UITextFieldAdv()
		{
			super();

	        if (!truncationIndicatorResource)
	        {
	            truncationIndicatorResource = resourceManager.getString(
	                "core", "truncationIndicator");
	        }
		}

	    /**
	     *  @private
	     */
	    protected var resourceManager:IResourceManager =
	                                    ResourceManager.getInstance();

	    /**
	     *  @private
	     *  Most resources are fetched on the fly from the ResourceManager,
	     *  so they automatically get the right resource when the locale changes.
	     *  But since truncateToFit() can be called frequently,
	     *  this class caches this resource value in this variable
	     *  and updates it when the locale changes.
	     */ 
	    protected static var truncationIndicatorResource:String;

	    public function truncateToFitHeight(measuredWidth:Number, measuredHeight:Number, truncationIndicator:String = null):Boolean
	    {
	        if (!truncationIndicator)
	            truncationIndicator = truncationIndicatorResource;

	        // Ensure that the proper CSS styles get applied to the textField
	        // before measuring text.
	        // Otherwise the callLater(validateNow) in styleChanged()
	        // can apply the CSS styles too late.
	        validateNow();
	
			var originalText:String = super.text;

	        var w:Number = measuredWidth;
	        var h:Number = measuredHeight;
	        width = measuredWidth;
	        height = measuredHeight;

			var lineMetrics:TextLineMetrics = getLineMetrics( 0 );

	        if ( h + TEXT_HEIGHT_PADDING > height )
	        	h = height;

			if ( lineMetrics && h < lineMetrics.height + TEXT_HEIGHT_PADDING )
				h = lineMetrics.height + TEXT_HEIGHT_PADDING;
	
	        // Need to check if we should truncate, but it 
	        // could be due to rounding error.  Let's check that it's not.
	        // Examples of rounding errors happen with "South Africa" and "Game"
	        // with verdana.ttf.
	        if (originalText != "" && 
	        		( textWidth + TEXT_WIDTH_PADDING > w + 0.00000000000001 ||
	        		  textHeight + TEXT_HEIGHT_PADDING > h + 0.00000000000001 ) )
	        {
	            // This should get us into the ballpark.
	            var s:String = super.text = originalText;
	            var cursor:int = originalText.length - 1;
	            var diff:int = originalText.length / 2;

				if ( textHeight + TEXT_HEIGHT_PADDING > h )
				{
		            while ( cursor > 0 && ( diff > 1 || textHeight + TEXT_HEIGHT_PADDING > h ) )
		            {
		                s = originalText.substr(0, cursor);
		                super.text = s + truncationIndicator;
		                
		                if ( textHeight + TEXT_HEIGHT_PADDING > h )
		                {
		                	cursor -= diff;
		                }
		                else
		                {
		                	cursor += diff;
		                }
	                	diff = Math.ceil( diff / 2 );
		            }
				}
				else if ( !wordWrap )
				{
		            while ( cursor > 0 && ( diff > 1 || textWidth + TEXT_WIDTH_PADDING > w ) )
		            {
		                s = originalText.substr(0, cursor);
		                super.text = s + truncationIndicator;
		                
		                if ( textWidth + TEXT_WIDTH_PADDING > w )
		                {
		                	cursor -= diff;
		                }
		                else
		                {
		                	cursor += diff;
		                }
	                	diff = Math.ceil( diff / 2 );
		            }
				}	            
	            return true;
	        }
	
	        return false;
	    }

	    public function truncateToFitHeightHTML(measuredWidth:Number, measuredHeight:Number, htmlInfo:HTMLInfo = null, truncationIndicator:String = null):Boolean
	    {
	        if (!truncationIndicator)
	            truncationIndicator = truncationIndicatorResource;

	        // Ensure that the proper CSS styles get applied to the textField
	        // before measuring text.
	        // Otherwise the callLater(validateNow) in styleChanged()
	        // can apply the CSS styles too late.
	        validateNow();

			var originalText:String = super.htmlText;

	        var w:Number = measuredWidth;
	        var h:Number = measuredHeight;
	        width = measuredWidth;
	        height = measuredHeight;

			var lineMetrics:TextLineMetrics = getLineMetrics( 0 );
			var nextLine:int = Math.min( 1, getLineIndexOfChar( length - 1 ) );
			var lineTwoMetrics:TextLineMetrics = nextLine != -1 ? getLineMetrics( nextLine ) : lineMetrics;
	
	        if ( h + TEXT_HEIGHT_PADDING > height )
	        	h = height;

			if ( lineMetrics && h < lineMetrics.height + TEXT_HEIGHT_PADDING )
				h = lineMetrics.height + TEXT_HEIGHT_PADDING;
	
	        // Need to check if we should truncate, but it 
	        // could be due to rounding error.  Let's check that it's not.
	        // Examples of rounding errors happen with "South Africa" and "Game"
	        // with verdana.ttf.
	        if (originalText != "" && 
	        		( textWidth + TEXT_WIDTH_PADDING > w + 0.00000000000001 ||
	        		  textHeight + TEXT_HEIGHT_PADDING > h + 0.00000000000001 ) )
	        {
				if ( !htmlInfo ) htmlInfo = parseHTML( originalText );
				var cursor:int = originalText.length - 1;
				var diff:int = Math.ceil( cursor / 2 );

				if ( textHeight + TEXT_HEIGHT_PADDING > h )
				{
					// we need to truncate by width
		            while ( cursor > 0 && ( diff > 1 || textHeight + TEXT_HEIGHT_PADDING > h ) )
		            {
		                super.htmlText = sliceHTML( htmlInfo, 0, cursor, truncationIndicator );

		                if ( textHeight + TEXT_HEIGHT_PADDING > h )
		                {
		                	cursor -= diff;
		                }
		                else
		                {
		                	cursor += diff;
		                }
	                	diff = Math.ceil( diff / 2 );
		            }
				}
				else if ( !wordWrap )
				{
					// we need to truncate by width
		            while ( cursor > 0 && ( diff > 1 || textWidth + TEXT_WIDTH_PADDING > w ) )
		            {
		                super.htmlText = sliceHTML( htmlInfo, 0, cursor, truncationIndicator );

		                if ( textWidth + TEXT_WIDTH_PADDING > w )
		                {
		                	cursor -= diff;
		                }
		                else
		                {
		                	cursor += diff;
		                }
	                	diff = Math.ceil( diff / 2 );
		            }
				}	            
	            return true;
	        }
	
	        return false;
	    }
	    public function truncateToFitHTML( htmlInfo:HTMLInfo = null, truncationIndicator:String = null):Boolean
	    {
	        if (!truncationIndicator)
	            truncationIndicator = truncationIndicatorResource;

	        // Ensure that the proper CSS styles get applied to the textField
	        // before measuring text.
	        // Otherwise the callLater(validateNow) in styleChanged()
	        // can apply the CSS styles too late.
	        validateNow();

			var originalText:String = super.htmlText;

	        var w:Number = width;
	        width = measuredWidth;

			var lineMetrics:TextLineMetrics = getLineMetrics( 0 );
			var nextLine:int = Math.min( 1, getLineIndexOfChar( length - 1 ) );
			var lineTwoMetrics:TextLineMetrics = nextLine != -1 ? getLineMetrics( nextLine ) : lineMetrics;
	
	        // Need to check if we should truncate, but it 
	        // could be due to rounding error.  Let's check that it's not.
	        // Examples of rounding errors happen with "South Africa" and "Game"
	        // with verdana.ttf.
	        if (originalText != "" && textWidth + TEXT_WIDTH_PADDING > w + 0.00000000000001 )
	        {
				if ( !htmlInfo ) htmlInfo = parseHTML( originalText );
				var cursor:int = originalText.length - 1;
				var diff:int = Math.ceil( cursor / 2 );

				// we need to truncate by width
	            while ( cursor > 0 && ( diff > 1 || textWidth + TEXT_WIDTH_PADDING > w ) )
	            {
	                super.htmlText = sliceHTML( htmlInfo, 0, cursor, truncationIndicator );

	                if ( textWidth + TEXT_WIDTH_PADDING > w )
	                {
	                	cursor -= diff;
	                }
	                else
	                {
	                	cursor += diff;
	                }
                	diff = Math.ceil( diff / 2 );
	            }

	            return true;
	        }
	
	        return false;
	    }

		public static function parseHTML( text:String ):HTMLInfo
		{
			var cursor:int = 0;
			var len:int = text.length;
			var entities:Array = [];
			var tokenStack:Array = [];
			var token:Token;
			var tokenId:int = 0;

			while ( cursor < len )
			{
				var char:String = text.charAt( cursor );
				
				// start of markup
				if ( char == "<" )
				{
					var tokenStart:int = cursor;

					// get end of tag
					var tokenEnd:int = text.indexOf( ">", tokenStart );
					
					// if not found ( mal formed ), just jump to end of text
					if ( tokenEnd == -1 ) tokenEnd = len;
					
					var newToken:Token = new Token( text.substring( tokenStart, tokenEnd + 1 ), tokenStart, tokenId++ );
					if ( !newToken.isClosing || newToken.isStubbed )
					{
						tokenStack.push( newToken );
					}
					else
					{
						// find closing token
						// closing tokens with no matching opening tokens are ignored
						for ( var i:int = tokenStack.length - 1; i >= 0; i-- )
						{
							var stackToken:Token = tokenStack[ i ] as Token;
							if ( stackToken.isTag && !stackToken.isClosing && stackToken.name == newToken.name )
							{
								// found the closing token, we will create closing
								// tags for anything in between
								
								// create closing tags for everything in between
								for ( var j:int = i + 1; j < tokenStack.length; j++ )
								{
									var orphanedToken:Token = tokenStack[ j ] as Token;
									if ( orphanedToken.isTag && !orphanedToken.isStubbed && !orphanedToken.isClosing )
									{
										var closeToken:Token = new Token( "</" + orphanedToken.name + ">", newToken.start, tokenId++ );
										closeToken.refid = orphanedToken.id;
	
										// add new close token to stack
										tokenStack.push( closeToken );
									}
								}
								
								// link new token with the ref token
								newToken.refid = stackToken.id;

								// add new token into stack
								tokenStack.push( newToken );
								break;
							}
						}
					}

					cursor += newToken.text.length;
				}
				else
				{
					var isHTMLEntity:Boolean = false;
					var charEnd:int;

					// check if character is a HTML entity
					if ( char == "&" )
					{
						charEnd = text.indexOf( ";", cursor );

						if ( charEnd != -1 )
						{
							var charText:String = text.substring( cursor, charEnd + 1 ).toLowerCase();

							// character code
							if ( charText.charAt(1) == "#" )
							{
								// unicode
								if ( charText.charAt(2) == "x" && !isNaN( parseInt( charText.substr(3), 16 ) ) )
									isHTMLEntity = true;
								// ascii code
								else if ( !isNaN( parseInt( charText.substr(2), 16 ) ) )
									isHTMLEntity = true;
							}
							// recognized HTML entities
							else switch ( charText )
							{
								case "&amp;":
								case "&quot;":
								case "&lt;":
								case "&gt;":
								case "&apos;":
									isHTMLEntity = true;
							}
						}
					}

					if ( isHTMLEntity )
					{
						// add as entity
						tokenStack.push( new Token( charText, cursor, tokenId++ ) );
						cursor = charEnd;
					}
					else
					{
						tokenStack.push( new Token( char, cursor, tokenId++ ) );
					}

					cursor++;
				}
			}

			return new HTMLInfo( tokenStack );
		}

		public static function sliceHTML(htmlInfo:HTMLInfo, startIndex:Number = 0, endIndex:Number = 0x7fffffff, append:String = ""):String
		{
			var ret:String;
			var cursor:int = 0;
			var sliceStack:Array = [];
			
			if ( startIndex >= 0 && endIndex >=0 && endIndex <= startIndex )
				return "";

			for each ( var token:Token in htmlInfo.tokens )
			{
				if ( cursor >= startIndex && cursor <= endIndex )
				{
					sliceStack.push( token );

					if ( token.isTag )
					{
						if ( token.isClosing )
						{
							// we got a closing tag
							// check if we already have it's open tag
							// in our sliced stack
							var refToken:Token = findRefToken( sliceStack, token.refid );
	
							if ( !refToken )
							{
								// uh oh! the opening tag for our closing
								// tag is not already in our slice list,
								// let's get it from the original list of tokens
								refToken = findRefToken( htmlInfo.tokens, token.refid );

								if ( refToken )
								{
									// okay.. we found it, let's add it to the top of our
									// stack
									sliceStack.unshift( refToken );
								}
								else
								{
									// whoops! no opening tag for our closing tag!
									// oh well, what can we do but carry on
								}
							}
						}
					}
				}

				if ( !token.isTag ) cursor++;

				if ( cursor >= endIndex ) break;
			}
			
			if ( append && append != "" )
			{
				// now let's add our appended text
				sliceStack.push( new Token( append, 0, -1 ) );
			}
			
			// okay now that we have our sliced stack, we need to close up
			// any orphaned tags that was not closed
			if ( sliceStack.length )
			{
				var lastToken:Token = sliceStack[ sliceStack.length - 1 ] as Token;
				var tokenId:uint = lastToken.id;
				
				for ( var i:int = 0; i < sliceStack.length; i++ )
				{
					var orphanedToken:Token = sliceStack[ i ] as Token;

					if ( orphanedToken.isTag && !orphanedToken.isStubbed && !orphanedToken.isClosing )
					{
						var isClosed:Boolean = false;
						// okay we found an opening tag, now let's see if it has a closing tag
						for ( var j:int = i + 1; j < sliceStack.length; j++ )
						{
							var closingToken:Token = sliceStack[ j ] as Token;
							if ( closingToken.refid == orphanedToken.id )
							{
								isClosed = true;
								break;
							}
						}
						
						if ( !isClosed )
						{
							// uh oh! this opening tag did not have a closing tag in
							// our stack. We need to create a close for it
							var closeToken:Token = new Token( "</" + orphanedToken.name + ">", lastToken.start, tokenId++ );
							closeToken.refid = orphanedToken.id;
		
							// add new close token to stack
							sliceStack.push( closeToken );
						}
					}
				}
			
				// alright, now let's join the tokens back into an HTML string
				ret = "";
				for each ( var joinToken:Token in sliceStack )
				{
					ret += joinToken.text;
				}
			}
			
			return ret;
		}
		
		protected static function findRefToken( tokenList:Array, refId:int ):Token
		{
			var ret:Token;
			for each ( var token:Token in tokenList )
			{
				if ( token.id == refId )
				{
					ret = token;
					break;
				}
			}
			return ret;
		} 
	}
}

class Token
{
	public function Token( text:String, start:uint, id:int = -1 )
	{
		this.text = text;
		this.start = start;
		this.id = id;
	}
	
	protected var _text:String;
	public function get text():String
	{
		return _text;
	}
	public function set text( value:String ):void
	{
		_text = value;
		_name = null;
		if ( text != null )
		{
			_isTag = ( text.charAt( 0 ) == "<" );
			_isClosing = ( isTag && text.charAt( 1 ) == "/" );
			_isStubbed = ( isTag && ( name == "img" || name == "br" || text.charAt( text.length - 2 ) == "/" ) );
		}
		else
		{
			_isTag = false;
			_isClosing = false;
			_isStubbed = false;
		}
	}

	public var start:uint;
	public function get end():uint
	{
		return start + text.length;
	}

	public var id:int;
	public var refid:int = -1;

	private var _isTag:Boolean = false;
	public function get isTag():Boolean
	{
		return _isTag;
	}

	private var _isStubbed:Boolean = false;
	public function get isStubbed():Boolean
	{
		return _isStubbed;
	}

	private var _isClosing:Boolean = false;
	public function get isClosing():Boolean
	{
		return _isClosing;
	}
	
	private var _name:String;
	public function get name():String
	{
		var ret:String = _name;
		
		if ( ret == null && isTag )
		{
			if ( isClosing )
			{
				// closing tag
				ret = text.substring( 2, text.length - 1 );
			}
			else
			{
				var i:int = text.indexOf(" ");
				if ( i == -1 )
				{
					// no attributes
					ret = text.substring( 1, text.length - 1 );
				}
				else
				{
					ret = text.substr( 1, i - 1 );
				}
			}
			ret = ret.replace( "/", "" );
			ret = ret.replace( " ", "" ).toLowerCase();

			_name = ret;
		}

		return ret;
	}
}

class HTMLInfo
{
	public function HTMLInfo( tokens:Array )
	{
		this.tokens = tokens;
	}
	
	private var _tokens:Array;
	public function get tokens():Array
	{
		return _tokens;
	}
	public function set tokens( value:Array ):void
	{
		_tokens = value;
		refresh();
	}

	private var _visibleChars:int;
	public function get visibleChars():int
	{
		return _visibleChars;
	}
	
	public function refresh():void
	{
		if ( tokens && tokens.length )
		{
			_visibleChars = 0;
			for each ( var token:Token in tokens )
			{
				// we count anything that is not a tag 
				// or is the line break tag as a visible character
				if ( !token.isTag || token.name == "br" ) _visibleChars++;
			}
		}
		else
		{
			_visibleChars = 0;
		}
	}
}
