import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice_assistant/secretKey.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiSecretKey",
        },
        body: jsonEncode({
          // we are apssing the parameter of api from
          //openAI documentation, Ai will get the response what a user want to ask
          //if yes then dallE API will be called else chatGPT Api
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with yes or no.',
            }
          ]
        }),
      );
      if (res.statusCode == 200) {
        // Status code 200 means everything is working well
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        switch (content) {
          // here yes is the case which we can get from the user as request
          case 'yes':
          case 'Yes':
          case 'yes.':
          case 'Yes.':
            final res = await dallEAPI(prompt); // calling dallE
            return res;
          default:
            final res = await chatGPTAPI(prompt); // calling chatGPT
            return res;
        }
      }
      return 'An internal error occured'; // if all the cases didn't match then this will print
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiSecretKey",
        },
        body: jsonEncode({"model": "gpt-3.5-turbo", "messages": messages}),
      );
      if (res.statusCode == 200) {
        // Status code 200 means everything is working well
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          'role': 'assistant',
          'content': content,
        });
      }
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
    return 'CHATGPT';
  }

//  DallE api functionality 

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiSecretKey",
        },
        body: jsonEncode({
          'prompt':prompt, // only needed the prompt which is defined in the parameter of api func
          'n' : 1, // it'll generate one image at a time if needed more then pass n = whatever
          }),
      );
      if (res.statusCode == 200) {
        // Status code 200 means everything is working well
        String imageUrl =
            jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();
        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
      }
      return 'An internal error occured';
    } catch (e) {
      return e.toString();
    }
    return 'dallE';
  }
}
