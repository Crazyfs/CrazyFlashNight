class Base64
{
	private static var keyStr:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

	public static function encode(input:String):String
	{
		var output:String = "";
		var chr1:Number, chr2:Number, chr3:Number;
		var enc1:Number, enc2:Number, enc3:Number, enc4:Number;
		var i:Number = 0;

		while (i < input.length)
		{
			chr1 = input.charCodeAt(i++);
			chr2 = i < input.length ? input.charCodeAt(i++) : NaN;
			chr3 = i < input.length ? input.charCodeAt(i++) : NaN;

			enc1 = chr1 >> 2;
			enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
			enc4 = chr3 & 63;

			if (isNaN(chr2))
			{
				enc3 = enc4 = 64;
			}
			else if (isNaN(chr3))
			{
				enc4 = 64;
			}

			output = output + keyStr.charAt(enc1) + keyStr.charAt(enc2) + keyStr.charAt(enc3) + keyStr.charAt(enc4);
		}

		return output;
	}

	public static function decode(input:String):String
	{
		var output:String = "";
		var chr1:Number, chr2:Number, chr3:Number;
		var enc1:Number, enc2:Number, enc3:Number, enc4:Number;
		var i:Number = 0;

		// 手动去掉非 Base64 字符
		input = removeInvalidBase64Chars(input);

		while (i < input.length)
		{
			enc1 = keyStr.indexOf(input.charAt(i++));
			enc2 = keyStr.indexOf(input.charAt(i++));
			enc3 = keyStr.indexOf(input.charAt(i++));
			enc4 = keyStr.indexOf(input.charAt(i++));

			chr1 = (enc1 << 2) | (enc2 >> 4);
			chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			chr3 = ((enc3 & 3) << 6) | enc4;

			output = output + String.fromCharCode(chr1);

			if (enc3 != 64)
			{
				output = output + String.fromCharCode(chr2);
			}
			if (enc4 != 64)
			{
				output = output + String.fromCharCode(chr3);
			}
		}

		return output;
	}

	private static function removeInvalidBase64Chars(input:String):String
	{
		var output:String = "";
		var base64Chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		for (var i:Number = 0; i < input.length; i++)
		{
			var char:String = input.charAt(i);
			if (base64Chars.indexOf(char) != -1)
			{
				output += char;
			}
		}
		return output;
	}
}