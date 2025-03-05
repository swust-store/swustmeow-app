import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swustmeow/entity/ai/ai_model.dart';
import 'package:swustmeow/entity/ai/ai_chat_message.dart';

class AIChatTestData {
  static List<AIModel> get models => [
    AIModel(
      id: 'gpt-3.5-turbo',
      name: 'GPT-3.5',
      description: '高效的智能助手，适合多种日常任务',
      icon: FontAwesomeIcons.robot,
    ),
    AIModel(
      id: 'gpt-4',
      name: 'GPT-4',
      description: '更强大的人工智能，擅长复杂任务与创意写作',
      icon: FontAwesomeIcons.brain,
    ),
    AIModel(
      id: 'claude-3',
      name: 'Claude 3',
      description: '擅长生成高质量文本与对话的智能助手',
      icon: FontAwesomeIcons.comment,
    ),
    AIModel(
      id: 'llama-3',
      name: 'Llama 3',
      description: '高性能开源大语言模型',
      icon: FontAwesomeIcons.dna,
    ),
  ];

  static List<AIChatMessage> get sampleMessages => [
    AIChatMessage.user(
      content: '你好，请介绍一下自己',
    ),
    AIChatMessage.assistant(
      content: '你好！我是一个人工智能助手，可以回答问题、提供信息、进行对话等。我能够理解和处理自然语言，帮助你完成各种任务。有什么我可以帮助你的吗？',
      isComplete: true,
    ),
    AIChatMessage.user(
      content: '什么是Flutter？',
    ),
    AIChatMessage.assistant(
      content: 'Flutter是Google开发的开源UI框架，用于构建跨平台应用程序。使用Flutter，开发者可以用单一代码库构建适用于Android、iOS、Web、Windows、macOS和Linux的应用。\n\nFlutter主要特点包括：\n\n1. 跨平台开发：一套代码运行在多个平台\n2. 热重载：快速看到代码更改的效果\n3. 自定义UI组件：丰富的可自定义组件库\n4. 性能优异：直接编译为原生代码\n5. Dart语言：专为UI优化的编程语言\n\n许多公司使用Flutter开发应用，包括Google自己的多个产品，如Google广告、Google Pay等。',
      isComplete: true,
    ),
  ];
} 