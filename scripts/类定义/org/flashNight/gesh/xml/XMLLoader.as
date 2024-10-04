class org.flashNight.gesh.xml.XMLLoader
{
    private var xml:XML;
    private var onLoadHandler:Function;

    /**
     * 构造函数，初始化 XMLLoader
     * @param xml文件地址 要加载的 XML 文件地址。
     * @param onLoadHandler 加载完成后的处理函数，接收 XML 数据作为参数。
     */
    public function XMLLoader(xml文件地址:String, onLoadHandler:Function)
    {
        this.xml = new XML();
        this.xml.ignoreWhite = true;
        this.onLoadHandler = onLoadHandler;

        var self:XMLLoader = this;
        this.xml.onLoad = function(加载成功:Boolean):Void {
            if (加载成功)
            {
                self.handleXMLLoad();
            }
            else
            {
                // 可以在这里添加错误处理逻辑
            }
        };
        this.xml.load(xml文件地址);
    }

    /**
     * 处理 XML 加载完成后的逻辑。
     */
    private function handleXMLLoad():Void
    {
        if (this.onLoadHandler != null)
        {
            this.onLoadHandler(this.xml.firstChild);
        }
    }
}