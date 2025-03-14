#!/usr/bin/env python3
"""
AWS Bedrock LangChain統合テスト
- Claude 3.5 Sonnet (チャット)
- Titan Text Embeddings V2 (埋め込み)
"""

from langchain_aws import ChatBedrock
from langchain_aws.embeddings import BedrockEmbeddings
from langchain_core.prompts import ChatPromptTemplate
import numpy as np

from pydantic import BaseModel, Field

class ProgrammingLanguage(BaseModel):
    summary: str = Field(description="短い説明")
    alias: str = Field(description="別名")


def test_claude_chat():
    """LangChainを使用してClaude 3.5 Sonnetモデルをテストする"""
    print("\n" + "="*50)
    print("LangChain + Claude 3.5 Sonnetモデルのテスト")
    print("="*50)
    
    try:
        # Claude 3.5 Sonnetモデルを初期化
        model_id = "anthropic.claude-3-5-sonnet-20240620-v1:0"
        
        # ChatBedrockモデルを初期化
        llm = ChatBedrock(
            model_id=model_id,
            region_name="ap-northeast-1",
            # region_name="us-east-1",
            model_kwargs={
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 1000
            }
        )
        
        # レスポンスの詳細情報を表示するコード
        
        # プロンプトの内容を表示
        print("\n=== プロンプトの内容 ===")
        template = """
        あなたは{language}の専門家です。
        言語について教えてください。
        """
        print(template.format(language="Python"))
        print("\n=== プロンプト終了 ===")
        
        # 構造化レスポンスを取得
        prompt = ChatPromptTemplate.from_template(template)
        print("\n=== 構造化レスポンスを取得 ===")
        structured_chain = prompt | llm.with_structured_output(ProgrammingLanguage)
        
        structured_response = structured_chain.invoke({
            "language": "Python",
        })
        
        print("\n構造化レスポンス:")
        print(structured_response.model_dump_json(indent=2))
        print("\n=== 構造化レスポンス終了 ===")
        
        return True
        
    except Exception as e:
        print(f"\nエラー: {str(e)}")
        print("\nAWSコンソールでモデルアクセスを有効にしてください:")
        print("1. AWS Bedrockコンソールにアクセス: https://console.aws.amazon.com/bedrock/")
        print("2. 左側メニューから「Model access」を選択")
        print("3. 「anthropic.claude-3-5-sonnet-20240620-v1:0」モデルを有効化")
        print("4. 「Request model access」ボタンをクリック")
        return False

def test_titan_embeddings():
    """LangChainを使用してTitan Text Embeddings V2モデルをテストする"""
    print("\n" + "="*50)
    print("LangChain + Amazon Titan Text Embeddings V2モデルのテスト")
    print("="*50)
    
    try:
        # Titan Text Embeddings V2モデルを初期化
        model_id = "amazon.titan-embed-text-v2:0"
        
        # BedrockEmbeddingsモデルを初期化
        embeddings = BedrockEmbeddings(
            model_id=model_id,
            region_name="ap-northeast-1",
            model_kwargs={
                "dimensions": 512,
                "normalize": True
            }
        )
        
        print(f"Titan Text Embeddings V2モデル({model_id})を呼び出しています...")
        
        # テキストを準備
        texts = [
            "AWS Bedrockは、高性能な基盤モデル（FM）を利用できるAWSのサービスです。",
            "機械学習モデルを簡単に利用できるようにするサービス。",
            "自然言語処理と画像生成の機能を提供します。"
        ]
        
        # 埋め込みベクトルを取得
        embeddings_list = embeddings.embed_documents(texts)
        
        # 埋め込みベクトルの情報を表示
        for i, (text, embedding) in enumerate(zip(texts, embeddings_list)):
            print(f"\nテキスト {i+1}: \"{text}\"")
            print(f"埋め込みベクトルの次元数: {len(embedding)}")
            print(f"埋め込みベクトルの最初の5要素: {embedding[:5]}...")
        
        # 類似度計算のデモ
        if len(embeddings_list) >= 3:
            # コサイン類似度を計算する関数
            def cosine_similarity(a, b):
                return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
            
            # テキスト間の類似度を計算
            sim_1_2 = cosine_similarity(embeddings_list[0], embeddings_list[1])
            sim_1_3 = cosine_similarity(embeddings_list[0], embeddings_list[2])
            sim_2_3 = cosine_similarity(embeddings_list[1], embeddings_list[2])
            
            print("\n類似度計算結果:")
            print(f"テキスト1とテキスト2の類似度: {sim_1_2:.4f}")
            print(f"テキスト1とテキスト3の類似度: {sim_1_3:.4f}")
            print(f"テキスト2とテキスト3の類似度: {sim_2_3:.4f}")
        
        # 単一テキストの埋め込み
        single_text = "LangChainを使ってAWS Bedrockと簡単に連携できます。"
        single_embedding = embeddings.embed_query(single_text)
        
        print(f"\n単一テキスト: \"{single_text}\"")
        print(f"埋め込みベクトルの次元数: {len(single_embedding)}")
        print(f"埋め込みベクトルの最初の5要素: {single_embedding[:5]}...")
            
        return True
        
    except Exception as e:
        print(f"\nエラー: {str(e)}")
        print("\nAWSコンソールでモデルアクセスを有効にしてください:")
        print("1. AWS Bedrockコンソールにアクセス: https://console.aws.amazon.com/bedrock/")
        print("2. 左側メニューから「Model access」を選択")
        print("3. 「amazon.titan-embed-text-v2:0」モデルを有効化")
        print("4. 「Request model access」ボタンをクリック")
        return False



def main():
    print("AWS Bedrock LangChain統合テスト")
    print("対象モデル: Claude 3.5 Sonnet, Amazon Titan Text Embeddings V2")
    
    # トークン使用量を確認するためのコード
    try:
        # CloudWatch Metricsからトークン消費を確認する方法を表示
        print("\nトークン消費を確認する方法:")
        print("1. AWSコンソールでCloudWatchにアクセスしてください")
        print("2. Metrics > All metrics > AWS/Bedrockを選択")
        print("3. ModelInvocationMetricsを選択")
        print("4. InputTokenCountとOutputTokenCountのメトリクスを確認")
        print("\nまたは、AWS CLIで確認する場合:")
        print("aws cloudwatch get-metric-statistics --namespace AWS/Bedrock --metric-name InputTokenCount --dimensions Name=ModelId,Value=anthropic.claude-3-5-sonnet-20240620-v1:0 --start-time $(date -d '1 hour ago' --iso-8601=seconds) --end-time $(date --iso-8601=seconds) --period 3600 --statistics Sum")
    except Exception as e:
        print(f"\nメトリクス確認中のエラー: {str(e)}")
    
    # Claude 3.5 Sonnetをテスト (ChatBedrock)
    claude_chat_success = test_claude_chat()
    
    # Titan Text Embeddings V2をテスト - スキップ
    # titan_success = test_titan_embeddings()
    
    # 結果サマリー
    print("\n" + "="*50)
    print("テスト結果サマリー")
    print("="*50)
    print(f"LangChain ChatBedrock + Claude 3.5 Sonnet: {'成功' if claude_chat_success else '失敗'}")
    
    if not claude_chat_success:
        print("\n一部のモデルへのアクセスが失敗しました。")
        print("AWSコンソールでモデルアクセスを有効にしてください。")
    else:
        print("\nすべてのモデルテストが成功しました！")
        print("\nLangChainを使用することで、より簡単にAWS Bedrockのモデルを利用できます。")
        print("詳細なドキュメントは以下を参照してください：")
        print("- LangChain: https://python.langchain.com/docs/get_started/introduction")
        print("- LangChain AWS: https://python.langchain.com/docs/integrations/llms/bedrock")

if __name__ == "__main__":
    main()