class org.flashNight.naki.DataStructures.TreeNode
{
	public var value:Number;// The value held by the node
	public var left:TreeNode;// Reference to the left child
	public var right:TreeNode;// Reference to the right child

	// Constructor to initialize the node with a value
	public function TreeNode(value:Number)
	{
		this.value = value;
		this.left = null;
		this.right = null;
	}
}