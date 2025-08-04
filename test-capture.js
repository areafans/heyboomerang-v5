const OpenAI = require('openai');

// Test script to validate the OpenAI function calling implementation
async function testFunctionCalling() {
  const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,
  });

  const systemPrompt = `You are an AI assistant for Small service business. 

Analyze voice transcriptions from the business owner and generate actionable business tasks.

IMPORTANT: You MUST always generate at least one task from any transcription.

Task types:
- follow_up: Communication with a specific contact/client (use when names are mentioned)
- reminder: Personal reminder/todo for the business owner (use for "remind me", personal tasks, shopping, etc.)
- campaign: Marketing message to multiple contacts (use for broad outreach)

RULES:
1. For "Remind me to..." phrases, ALWAYS create a reminder task with contactName: "Business Owner"
2. For personal tasks (shopping, appointments, todos), create reminder tasks
3. Extract contact information when mentioned, otherwise use appropriate defaults
4. Choose appropriate timing based on urgency (immediate for urgent, tomorrow for most tasks)
5. Always provide clear, actionable messages

Example: "Remind me to pick up drywall" → reminder task with contactName: "Business Owner", message: "Pick up drywall", timing: "tomorrow"`;

  const tools = [{
    type: "function",
    function: {
      name: "generate_tasks",
      description: "Generate actionable business tasks from voice transcription",
      parameters: {
        type: "object",
        properties: {
          tasks: {
            type: "array",
            items: {
              type: "object",
              properties: {
                type: {
                  type: "string",
                  enum: ["follow_up", "reminder", "campaign"],
                  description: "Type of task to create"
                },
                contactName: {
                  type: "string",
                  description: "Contact name from transcription, 'Business Owner' for reminders, or 'Unknown Contact'"
                },
                contactPhone: {
                  type: "string",
                  description: "Phone number if mentioned in transcription"
                },
                contactEmail: {
                  type: "string", 
                  description: "Email address if mentioned in transcription"
                },
                message: {
                  type: "string",
                  description: "Clear, actionable message text or reminder description"
                },
                timing: {
                  type: "string",
                  enum: ["immediate", "end_of_day", "tomorrow", "next_week"],
                  description: "When this task should be executed"
                }
              },
              required: ["type", "contactName", "message", "timing"],
              additionalProperties: false
            }
          }
        },
        required: ["tasks"],
        additionalProperties: false
      }
    }
  }];

  const transcription = "Remind me to pick up drywall";

  try {
    console.log('🚀 Testing OpenAI function calling...');
    console.log('📝 Transcription:', transcription);
    
    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: `Transcription: "${transcription}"` }
      ],
      tools,
      tool_choice: { type: "function", function: { name: "generate_tasks" } },
      temperature: 0.7,
      max_tokens: 1000,
    });

    console.log('✅ OpenAI Response received');
    console.log('🤖 Full response:', JSON.stringify(completion, null, 2));

    const toolCall = completion.choices[0]?.message?.tool_calls?.[0];
    if (!toolCall || toolCall.function.name !== "generate_tasks") {
      console.error('❌ No valid tool call returned');
      return;
    }

    const aiResponse = JSON.parse(toolCall.function.arguments);
    console.log('📋 Parsed response:', aiResponse);
    console.log(`📊 Generated ${aiResponse.tasks?.length || 0} tasks`);

    if (aiResponse.tasks && aiResponse.tasks.length > 0) {
      console.log('✅ SUCCESS: Tasks generated correctly!');
      aiResponse.tasks.forEach((task, index) => {
        console.log(`Task ${index + 1}:`, task);
      });
    } else {
      console.error('❌ FAILURE: No tasks generated');
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error('Full error:', error);
  }
}

// Run the test if OPENAI_API_KEY is set
if (process.env.OPENAI_API_KEY) {
  testFunctionCalling();
} else {
  console.log('⚠️ OPENAI_API_KEY not set. Please set it to run this test.');
  console.log('Usage: OPENAI_API_KEY=your_key node test-capture.js');
}