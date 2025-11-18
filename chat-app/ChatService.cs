using Azure;
using Azure.AI.OpenAI;

namespace ChatApp;

public class AzureOpenAIConfig
{
    public string Endpoint { get; set; } = string.Empty;
    public string ApiKey { get; set; } = string.Empty;
    public string DeploymentName { get; set; } = string.Empty;
    public string ApiVersion { get; set; } = "2024-02-15-preview";
}

public class ChatService
{
    private readonly OpenAIClient _client;
    private readonly string _deploymentName;
    private readonly ILogger<ChatService> _logger;

    public ChatService(IConfiguration configuration, ILogger<ChatService> logger)
    {
        _logger = logger;
        
        var config = configuration.GetSection("AzureOpenAI").Get<AzureOpenAIConfig>()
            ?? throw new InvalidOperationException("AzureOpenAI configuration is missing");

        if (string.IsNullOrEmpty(config.Endpoint))
            throw new InvalidOperationException("AzureOpenAI Endpoint is not configured");
        
        if (string.IsNullOrEmpty(config.ApiKey))
            throw new InvalidOperationException("AzureOpenAI ApiKey is not configured");

        _deploymentName = config.DeploymentName ?? throw new InvalidOperationException("DeploymentName is not configured");

        // Configure for Azure Government
        var options = new OpenAIClientOptions
        {
            // Azure Government endpoint
        };

        _client = new OpenAIClient(
            new Uri(config.Endpoint),
            new AzureKeyCredential(config.ApiKey),
            options
        );

        _logger.LogInformation("Azure OpenAI Chat Service initialized for Azure Government");
    }

    public async Task<string> GetChatCompletionAsync(string userMessage, CancellationToken cancellationToken = default)
    {
        try
        {
            var chatCompletionsOptions = new ChatCompletionsOptions()
            {
                DeploymentName = _deploymentName,
                Messages =
                {
                    new ChatRequestSystemMessage("You are a helpful AI assistant."),
                    new ChatRequestUserMessage(userMessage)
                },
                MaxTokens = 800,
                Temperature = 0.7f
            };

            _logger.LogInformation("Sending chat completion request");
            
            Response<ChatCompletions> response = await _client.GetChatCompletionsAsync(
                chatCompletionsOptions,
                cancellationToken
            );

            var completion = response.Value.Choices[0].Message.Content;
            
            _logger.LogInformation("Received chat completion response");
            
            return completion ?? "No response generated";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting chat completion");
            throw;
        }
    }
}
