class org.flashNight.gesh.toml.TOMLLexerTest {
    
    // 最大递归深度
    private var MAX_RECURSION_DEPTH:Number = 10;

    /**
     * 运行所有的测试用例
     */
    public function runAllTests():Void {
        // 运行 Lexer 的测试用例
        trace("=== Running TOMLLexer Tests ===");
        this.testLexer();

        // 运行 Encoder 的测试用例
        trace("=== Running TOMLEncoder Tests ===");
        this.testTOMLEncoder();
    }

    /**
     * 测试 TOMLLexer
     */
    public function testLexer():Void {
        var tomlSamples:Array = this.getTestCases();

        for (var i:Number = 0; i < tomlSamples.length; i++) {
            var tomlText:String = tomlSamples[i].text;
            trace("=== Running test case " + (i + 1) + " ===");

            // 创建 Lexer 和解析器
            var lexer:org.flashNight.gesh.toml.TOMLLexer = new org.flashNight.gesh.toml.TOMLLexer(tomlText);
            var tokens:Array = [];
            var token:Object;

            // 获取所有 tokens 并存储
            while ((token = lexer.getNextToken()) != null) {
                tokens.push(token);
            }

            // 创建并调用解析器
            var parser:org.flashNight.gesh.toml.TOMLParser = new org.flashNight.gesh.toml.TOMLParser(tokens);
            var result:Object = parser.parse();

            // 检查解析器是否遇到错误
            if (parser.hasError()) {
                trace("Test Case " + (i + 1) + " - Parsing Error Detected.");
                trace("=== End of test case " + (i + 1) + " ===\n");
                continue; // 跳过比较步骤
            }

            // 将解析结果转换为 JSON 并输出
            var jsonString:String = org.flashNight.gesh.object.ObjectUtil.toJSON(result, true);
            trace("Test Case " + (i + 1) + " - JSON Output:");
            trace(jsonString);

            // 验证预期输出
            if (tomlSamples[i].expected !== null) {
                this.compareResults(result, tomlSamples[i].expected, 0);
            } else {
                trace("Skipping comparison due to invalid or missing expected output.");
            }
            trace("=== End of test case " + (i + 1) + " ===\n");
        }
    }

    /**
     * 获取 TOMLLexer 的测试用例
     */
    private function getTestCases():Array {
        return [
            {   // Test case 1: Basic TOML structure
                text: 'title = "My Game" # Comment\n' +
                      'isActive = true\n' +
                      'max_score = 1000\n' +
                      'average_score = 89.95\n' +
                      'launch_time = 2024-10-09T08:30:00Z\n' +
                      'items = ["sword", "shield", "potion"]\n' +
                      'description = """This is a multiline string.\nIt has multiple lines."""\n',
                expected: { 
                    title: "My Game",
                    isActive: true,
                    max_score: 1000,
                    average_score: 89.95,
                    launch_time: "2024-10-09T08:30:00Z",
                    items: ["sword", "shield", "potion"],
                    description: "This is a multiline string.\nIt has multiple lines."
                }
            },
            {   // Test case 2: Boolean values
                text: 'boolean_true = true\nboolean_false = false\n',
                expected: {
                    boolean_true: true,
                    boolean_false: false
                }
            },
            {   // Test case 3: Numbers
                text: 'integer = 42\nnegative_integer = -42\nfloat = 3.14\nnegative_float = -3.14\n',
                expected: {
                    integer: 42,
                    negative_integer: -42,
                    float: 3.14,
                    negative_float: -3.14
                }
            },
            {   // Test case 4: Empty values
                text: 'empty_string = ""\nempty_array = []\nnull_value = null\n',
                expected: {
                    empty_string: "",
                    empty_array: [],
                    null_value: null
                }
            },
            {   // Test case 5: Date and time
                text: 'date_time = 2024-10-09T08:30:00Z\n',
                expected: {
                    date_time: "2024-10-09T08:30:00Z"
                }
            },
            {   // Test case 6: Nested tables
                text: '[server]\n' +
                      'ip = "192.168.1.1"\n' +
                      '[server.database]\n' +
                      'type = "PostgreSQL"\n' +
                      'ports = [5432, 5433, 5434]\n' +
                      '[server.database.settings]\n' +
                      'enabled = true\n',
                expected: {
                    server: {
                        ip: "192.168.1.1",
                        database: {
                            type: "PostgreSQL",
                            ports: [5432, 5433, 5434],
                            settings: {
                                enabled: true
                            }
                        }
                    }
                }
            },
            {   // Test case 7: Table arrays
                text: '[[products]]\n' +
                      'name = "Hammer"\n' +
                      'sku = 738594937\n' +
                      '[[products]]\n' +
                      'name = "Nail"\n' +
                      'sku = 284758393\n',
                expected: {
                    products: [
                        { name: "Hammer", sku: 738594937 },
                        { name: "Nail", sku: 284758393 }
                    ]
                }
            },
            {   // Test case 8: Complex nested tables and table arrays
                text: 'title = "TOML Example"\n' +
                      'owner = { name = "Tom", dob = 1979-05-27 }\n' +
                      '[[products]]\n' +
                      'name = "Hammer"\n' +
                      'sku = 738594937\n' +
                      '[[products]]\n' +
                      'name = "Nail"\n' +
                      'sku = 284758393\n' +
                      '[database]\n' +
                      'server = "192.168.1.1"\n' +
                      'ports = [8001, 8001, 8002]\n' +
                      'connection_max = 5000\n' +
                      'enabled = true\n',
                expected: 'owner = { dob = "1979-05-27", name = "Tom" }\n' +
                          'title = "TOML Example"\n' +
                          '[[products]]\n' +
                          'name = "Hammer"\n' +
                          'sku = 738594937\n' +
                          '[[products]]\n' +
                          'name = "Nail"\n' +
                          'sku = 284758393\n' +
                          '[database]\n' +
                          'connection_max = 5000\n' +
                          'enabled = true\n' +
                          'ports = [8001, 8001, 8002]\n' +
                          'server = "192.168.1.1"\n'
            },
            {   // Test case 9: Unicode characters
                text: 'greeting = "こんにちは"\nemoji = "😊"\n',
                expected: {
                    greeting: "こんにちは",
                    emoji: "😊"
                }
            },
            {   // Test case 10: Escape characters
                text: 'escaped_newline = "Line1\\nLine2"\nescaped_quote = "He said, \\"Hello!\\""\n',
                expected: {
                    escaped_newline: "Line1\nLine2",
                    escaped_quote: 'He said, "Hello!"'
                }
            },
            {   // Test case 11: Mixed complex structures
                text: '[server]\n' +
                      'host = "localhost"\n' +
                      'ports = [8000, 8001, 8002]\n' +
                      'connection_max = 5000\n' +
                      'enabled = true\n' +
                      '[[owners]]\n' +
                      'name = "Alice"\n' +
                      'dob = "1990-01-01"\n' +
                      '[[owners]]\n' +
                      'name = "Bob"\n' +
                      'dob = "1985-05-12"\n' +
                      '[database]\n' +
                      'server = "192.168.1.100"\n' +
                      'ports = [3306]\n' +
                      'connection_max = 10000\n' +
                      'enabled = false\n' +
                      '[[users]]\n' +
                      'name = "user1"\n' +
                      'active = true\n' +
                      '[[users]]\n' +
                      'name = "user2"\n' +
                      'active = false\n',
                expected: '[[users]]\n' +
                          'active = true\n' +
                          'name = "user1"\n' +
                          '[[users]]\n' +
                          'active = false\n' +
                          'name = "user2"\n' +
                          '[server]\n' +
                          'connection_max = 5000\n' +
                          'enabled = true\n' +
                          'host = "localhost"\n' +
                          'ports = [8000, 8001, 8002]\n' +
                          '[[owners]]\n' +
                          'dob = "1990-01-01"\n' +
                          'name = "Alice"\n' +
                          '[[owners]]\n' +
                          'dob = "1985-05-12"\n' +
                          'name = "Bob"\n' +
                          '[database]\n' +
                          'connection_max = 10000\n' +
                          'enabled = false\n' +
                          'ports = [3306]\n' +
                          'server = "192.168.1.100"\n'
            }
        ];
    }

    /**
     * 测试 TOMLEncoder
     */
    public function testTOMLEncoder():Void {
        var testCases:Array = this.getEncoderTestCases();

        for (var i:Number = 0; i < testCases.length; i++) {
            var testObj:Object = testCases[i].input;
            var expected:String = testCases[i].expected;

            trace("=== Running encoding test case " + (i + 1) + " ===");

            // 使用 TOMLEncoder 进行编码
            var encoder:org.flashNight.gesh.toml.TOMLEncoder = new org.flashNight.gesh.toml.TOMLEncoder();
            var tomlOutput:String = encoder.encode(testObj, true); // true 表示美化输出

            trace("Encoded TOML Output:");
            trace(tomlOutput);

            // 验证结果
            if (testCases[i].expected !== null) {
                this.compareEncoderOutput(tomlOutput, testCases[i].expected);
            }

            trace("=== End of encoding test case " + (i + 1) + " ===\n");
        }
    }

    /**
     * 获取 TOMLEncoder 的测试用例
     */
    private function getEncoderTestCases():Array {
        return [
            {   // Test case 1: Simple object
                input: {
                    title: "My Game",
                    isActive: true,
                    max_score: 1000,
                    average_score: 89.95,
                    launch_time: new Date(2024, 9, 9, 8, 30, 0), // 注意：月份从0开始
                    items: ["sword", "shield", "potion"]
                },
                expected: 'average_score = 89.95\n' +
                          'isActive = true\n' +
                          'items = ["sword", "shield", "potion"]\n' +
                          'launch_time = 2024-10-09T08:30:00Z\n' +
                          'max_score = 1000\n' +
                          'title = "My Game"\n'
            },
            {   // Test case 2: Boolean values
                input: {
                    boolean_true: true,
                    boolean_false: false
                },
                expected: 'boolean_false = false\n' +
                          'boolean_true = true\n'
            },
            {   // Test case 3: Numbers
                input: {
                    integer: 42,
                    negative_integer: -42,
                    float: 3.14,
                    negative_float: -3.14
                },
                expected: 'float = 3.14\n' +
                          'integer = 42\n' +
                          'negative_float = -3.14\n' +
                          'negative_integer = -42\n'
            },
            {   // Test case 4: Empty values
                input: {
                    empty_string: "",
                    empty_array: [],
                    null_value: null
                },
                expected: 'empty_array = []\n' +
                          'empty_string = ""\n' +
                          'null_value = null\n'
            },
            {   // Test case 5: Date and time
                input: {
                    date_time: new Date(2024, 9, 9, 8, 30, 0)
                },
                expected: 'date_time = 2024-10-09T08:30:00Z\n'
            },
            {   // Test case 6: Nested tables
                input: {
                    server: {
                        ip: "192.168.1.1",
                        database: {
                            type: "PostgreSQL",
                            ports: [5432, 5433, 5434],
                            settings: {
                                enabled: true
                            }
                        }
                    }
                },
                expected: '[server]\n' +
                          'ip = "192.168.1.1"\n' +
                          '[server.database]\n' +
                          'ports = [5432, 5433, 5434]\n' +
                          'type = "PostgreSQL"\n' +
                          '[server.database.settings]\n' +
                          'enabled = true\n'
            },
            {   // Test case 7: Table arrays
                input: {
                    products: [
                        { name: "Hammer", sku: 738594937 },
                        { name: "Nail", sku: 284758393 }
                    ]
                },
                expected: '[[products]]\n' +
                          'name = "Hammer"\n' +
                          'sku = 738594937\n' +
                          '[[products]]\n' +
                          'name = "Nail"\n' +
                          'sku = 284758393\n'
            },
            {   // Test case 8: Complex nested tables and table arrays
                input: {
                    title: "TOML Example",
                    owner: { name: "Tom", dob: "1979-05-27" },
                    products: [
                        { name: "Hammer", sku: 738594937 },
                        { name: "Nail", sku: 284758393 }
                    ],
                    database: {
                        server: "192.168.1.1",
                        ports: [8001, 8001, 8002],
                        connection_max: 5000,
                        enabled: true
                    }
                },
                expected: 'owner = { dob = "1979-05-27", name = "Tom" }\n' +
                          'title = "TOML Example"\n' +
                          '[[products]]\n' +
                          'name = "Hammer"\n' +
                          'sku = 738594937\n' +
                          '[[products]]\n' +
                          'name = "Nail"\n' +
                          'sku = 284758393\n' +
                          '[database]\n' +
                          'connection_max = 5000\n' +
                          'enabled = true\n' +
                          'ports = [8001, 8001, 8002]\n' +
                          'server = "192.168.1.1"\n'
            },
            {   // Test case 9: Unicode characters
                input: {
                    greeting: "こんにちは",
                    emoji: "😊"
                },
                expected: 'emoji = "😊"\n' +
                          'greeting = "こんにちは"\n'
            },
            {   // Test case 10: Escape characters
                input: {
                    escaped_newline: "Line1\nLine2",
                    escaped_quote: 'He said, "Hello!"'
                },
                expected: 'escaped_newline = """Line1\nLine2"""\n' +
                          'escaped_quote = "He said, \\"Hello!\\""\n'
            },
            {   // Test case 11: Mixed complex structures
                input: {
                    server: {
                        host: "localhost",
                        ports: [8000, 8001, 8002],
                        connection_max: 5000,
                        enabled: true
                    },
                    owners: [
                        { name: "Alice", dob: "1990-01-01" },
                        { name: "Bob", dob: "1985-05-12" }
                    ],
                    database: {
                        server: "192.168.1.100",
                        ports: [3306],
                        connection_max: 10000,
                        enabled: false
                    },
                    users: [
                        { name: "user1", active: true },
                        { name: "user2", active: false }
                    ]
                },
                expected: '[[users]]\n' +
                          'active = true\n' +
                          'name = "user1"\n' +
                          '[[users]]\n' +
                          'active = false\n' +
                          'name = "user2"\n' +
                          '[server]\n' +
                          'connection_max = 5000\n' +
                          'enabled = true\n' +
                          'host = "localhost"\n' +
                          'ports = [8000, 8001, 8002]\n' +
                          '[[owners]]\n' +
                          'dob = "1990-01-01"\n' +
                          'name = "Alice"\n' +
                          '[[owners]]\n' +
                          'dob = "1985-05-12"\n' +
                          'name = "Bob"\n' +
                          '[database]\n' +
                          'connection_max = 10000\n' +
                          'enabled = false\n' +
                          'ports = [3306]\n' +
                          'server = "192.168.1.100"\n'
            }
        ];
    }

    /**
     * 比较解析结果和预期结果
     * @param actual 解析后的对象
     * @param expected 预期对象
     * @param depth 当前递归深度
     */
    private function compareResults(actual:Object, expected:Object, depth:Number):Void {
        if (depth > this.MAX_RECURSION_DEPTH) {
            trace("Exceeded max recursion depth. Stopping comparison.");
            return;
        }

        for (var key:String in expected) {
            if (typeof(expected[key]) == "object" && expected[key] !== null) {
                if (typeof(actual[key]) != "object" || actual[key] === null) {
                    trace("Mismatch on key: " + key + ", expected an object, but got " + actual[key]);
                    continue;
                }
                this.compareResults(actual[key], expected[key], depth + 1);
            } else {
                if (actual[key] !== expected[key]) {
                    trace("Mismatch on key: " + key + ", expected: " + expected[key] + ", actual: " + actual[key]);
                } else {
                    trace("Key: " + key + " passed.");
                }
            }
        }
    }

    /**
     * 比较编码后的 TOML 输出与预期输出
     * @param actual 实际编码输出
     * @param expected 预期编码输出
     */
    private function compareEncoderOutput(actual:String, expected:String):Void {
        var cleanedActual:String = this.trimTrailingNewlines(actual);
        var cleanedExpected:String = this.trimTrailingNewlines(expected);

        if (cleanedActual != cleanedExpected) {
            trace("Mismatch detected! \nExpected:\n" + cleanedExpected + "\nActual:\n" + cleanedActual);
        } else {
            trace("Encoded output matches the expected output.");
        }
    }

    /**
     * 去除字符串末尾的换行符
     */
    private function trimTrailingNewlines(input:String):String {
        while (input.length > 0) {
            var lastChar:String = input.charAt(input.length - 1);
            if (lastChar == "\n" || lastChar == "\r") {
                input = input.substr(0, input.length - 1);
            } else {
                break;
            }
        }
        return input;
    }
}


/*

// 导入相关类 (AS2 中没有真正的 import 语法，使用类的完整路径即可)
var test:org.flashNight.gesh.toml.TOMLLexerTest = new org.flashNight.gesh.toml.TOMLLexerTest();

// 调用测试方法，运行所有测试用例
test.runAllTests();

*/
