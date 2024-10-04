import org.flashNight.gesh.string.StringUtils;
import org.flashNight.gesh.xml.XMLLoader;

class org.flashNight.gesh.xml.XMLParser
{
    /**
     * 将输入配置数据确保为数组格式。
     * @param input 输入数据，可以是任何类型。
     * @return 数组格式的数据。
     */
    public static function configureDataAsArray(input):Array
    {
        if (input instanceof Array)
        {
            return input;
        }
        else if (input != undefined && input != null)
        {
            return [input];
        }
        else
        {
            return [];
        }
    }

    /**
     * 解析给定的 XML 节点并将其转换为对象。
     * @param node XMLNode 要解析的 XML 节点。
     * @return Object 解析后的对象。如果解析失败，返回 null。
     */
    public static function parseXMLNode(node:XMLNode):Object
    {
        // 如果节点无效或为空，返回 null
        if (node == null || !isValidXML(node)) {
            return null;
        }

        // 如果节点是文本节点，直接返回其值
        if (node.nodeType == 3) // TEXT_NODE
        {
            return convertDataType(node.nodeValue);
        }
        else if (node.nodeType == 4) // CDATA_SECTION_NODE
        {
            return node.nodeValue;
        }

        var result:Object = {};

        // 处理节点属性并进行类型转换
        for (var attr:String in node.attributes)
        {
            result[attr] = convertDataType(node.attributes[attr]);
        }

        // 处理子节点
        for (var i:Number = 0; i < node.childNodes.length; i++)
        {
            var childNode:XMLNode = node.childNodes[i];
            var nodeName:String = childNode.nodeName;

            // 跳过注释节点
            if (childNode.nodeType == 8) // COMMENT_NODE
            {
                continue;
            }

            if (childNode.hasChildNodes())
            {
                var childValue:Object;

                if (childNode.childNodes.length == 1 && childNode.firstChild.nodeType == 3)
                {
                    childValue = convertDataType(childNode.firstChild.nodeValue);
                }
                else
                {
                    childValue = parseXMLNode(childNode);
                }

                // 如果已经有同名节点，则转换为数组
                if (result[nodeName] !== undefined)
                {
                    if (!(result[nodeName] instanceof Array))
                    {
                        result[nodeName] = [result[nodeName]];
                    }
                    result[nodeName].push(childValue);
                }
                else
                {
                    result[nodeName] = childValue;
                }
            }
            else
            {
                // 子节点无值时处理为空字符串
                var nodeValue:Object = childNode.nodeValue == null ? "" : convertDataType(childNode.nodeValue);
                if (result[nodeName] !== undefined)
                {
                    if (!(result[nodeName] instanceof Array))
                    {
                        result[nodeName] = [result[nodeName]];
                    }
                    result[nodeName].push(nodeValue);
                }
                else
                {
                    result[nodeName] = nodeValue;
                }
            }
        }

        return result;
    }

    /**
     * 从包含 HTML 标签的 XML 节点中提取内部文本内容。
     * @param node XMLNode 包含 HTML 标签的父节点。
     * @return String 内部文本内容。
     */
    public static function getInnerText(node:XMLNode):String
    {
        var innerText:String = "";
        for (var i:Number = 0; i < node.childNodes.length; i++)
        {
            var child:XMLNode = node.childNodes[i];
            if (child.nodeType == 3 || child.nodeType == 4) // TEXT_NODE or CDATA_SECTION_NODE
            {
                innerText += child.nodeValue;
            }
        }
        return StringUtils.decodeHTML(innerText);
    }

    /**
     * 将字符串转换为适当的数据类型（数字、布尔值或字符串）。
     * @param value String 要转换的字符串。
     * @return Object 转换后的数据。
     */
    private static function convertDataType(value:String):Object
    {
        if (!isNaN(Number(value)))
        {
            return Number(value);
        }
        else if (value.toLowerCase() == "true")
        {
            return true;
        }
        else if (value.toLowerCase() == "false")
        {
            return false;
        }
        return value;
    }

    /**
     * 检查 XML 是否有效。
     * @param node XMLNode 要检查的 XML 节点。
     * @return Boolean 如果 XML 合法则返回 true，否则返回 false。
     */
    private static function isValidXML(node:XMLNode):Boolean {
        return node.nodeName != undefined && node.nodeName != null;
    }

	/**
     * 加载 XML 文件并处理其内容。
     * @param xml文件地址 要加载的 XML 文件地址。
     * @param onLoadHandler 加载完成后的处理函数，接收解析后的 XML 节点作为参数。
     */
    public static function loadAndParseXML(xml文件地址:String, onLoadHandler:Function):Void
    {
        new XMLLoader(xml文件地址, function(xmlNode:XMLNode):Void {
            var parsedData = XMLParser.parseXMLNode(xmlNode);
            onLoadHandler(parsedData);
        });
    }
}
