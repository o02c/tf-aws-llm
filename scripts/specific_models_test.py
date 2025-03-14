#!/usr/bin/env python3
"""
AWS Bedrock特定モデルテストスクリプト
- Claude 3.5 Sonnet
- Amazon Titan Text Embeddings V2
"""

import boto3
import json
import numpy as np

def test_claude():
    """Claude 3.5 Sonnetモデルをテストする"""
    print("\n" + "="*50)
    print("Claude 3.5 Sonnetモデルのテスト")
    print("="*50)
    
    try:
        # Bedrockランタイムクライアントを初期化
        bedrock_runtime = boto3.client(
            service_name='bedrock-runtime',
            region_name='ap-northeast-1'
        )
        
        # Claude 3.5 Sonnetモデルを呼び出す
        model_id = "anthropic.claude-3-5-sonnet-20240620-v1:0"
        
        # プロンプトを準備
        prompt = """
        <human>
        AWS Bedrockとは何ですか？また、どのような用途に使えますか？
        </human>
        """
        
        # リクエストボディを準備
        request_body = {
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 1000,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": prompt
                        }
                    ]
                }
            ]
        }
        
        print(f"Claude 3.5 Sonnetモデル({model_id})を呼び出しています...")
        
        # モデルを呼び出す
        response = bedrock_runtime.invoke_model(
            modelId=model_id,
            contentType="application/json",
            accept="application/json",
            body=json.dumps(request_body)
        )
        
        # レスポンスを解析
        response_body = json.loads(response.get('body').read())
        
        print("\nClaudeからの応答:")
        if "content" in response_body:
            for content in response_body.get("content", []):
                if content.get("type") == "text":
                    print(content.get("text"))
        else:
            print(response_body)
            
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
    """Amazon Titan Text Embeddings V2モデルをテストする"""
    print("\n" + "="*50)
    print("Amazon Titan Text Embeddings V2モデルのテスト")
    print("="*50)
    
    try:
        # Bedrockランタイムクライアントを初期化
        bedrock_runtime = boto3.client(
            service_name='bedrock-runtime',
            region_name='ap-northeast-1'
        )
        
        # Titan Text Embeddings V2モデルを呼び出す
        model_id = "amazon.titan-embed-text-v2:0"
        
        # テキストを準備
        texts = [
            "AWS Bedrockは、高性能な基盤モデル（FM）を利用できるAWSのサービスです。",
            "機械学習モデルを簡単に利用できるようにするサービス。",
            "自然言語処理と画像生成の機能を提供します。"
        ]
        
        print(f"Titan Text Embeddings V2モデル({model_id})を呼び出しています...")
        
        # 各テキストの埋め込みベクトルを取得
        embeddings = []
        for i, text in enumerate(texts):
            # リクエストボディを準備
            request_body = {
                "inputText": text,
                "dimensions": 512,
                "normalize": True
            }
            
            # モデルを呼び出す
            response = bedrock_runtime.invoke_model(
                modelId=model_id,
                contentType="application/json",
                accept="*/*",
                body=json.dumps(request_body)
            )
            
            # レスポンスを解析
            response_body = json.loads(response.get('body').read())
            embedding = response_body.get("embedding")
            
            # 埋め込みベクトルの一部を表示
            print(f"\nテキスト {i+1}: \"{text}\"")
            print(f"埋め込みベクトルの次元数: {len(embedding)}")
            print(f"埋め込みベクトルの最初の5要素: {embedding[:5]}...")
            
            embeddings.append(embedding)
        
        # 類似度計算のデモ
        if len(embeddings) >= 3:
            # コサイン類似度を計算する関数
            def cosine_similarity(a, b):
                return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))
            
            # テキスト間の類似度を計算
            sim_1_2 = cosine_similarity(embeddings[0], embeddings[1])
            sim_1_3 = cosine_similarity(embeddings[0], embeddings[2])
            sim_2_3 = cosine_similarity(embeddings[1], embeddings[2])
            
            print("\n類似度計算結果:")
            print(f"テキスト1とテキスト2の類似度: {sim_1_2:.4f}")
            print(f"テキスト1とテキスト3の類似度: {sim_1_3:.4f}")
            print(f"テキスト2とテキスト3の類似度: {sim_2_3:.4f}")
            
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
    print("AWS Bedrock特定モデルテスト")
    print("対象モデル: Claude 3.5 Sonnet, Amazon Titan Text Embeddings V2")
    
    # Claude 3.5 Sonnetをテスト
    claude_success = test_claude()
    
    # Titan Text Embeddings V2をテスト
    titan_success = test_titan_embeddings()
    
    # 結果サマリー
    print("\n" + "="*50)
    print("テスト結果サマリー")
    print("="*50)
    print(f"Claude 3.5 Sonnet: {'成功' if claude_success else '失敗'}")
    print(f"Titan Text Embeddings V2: {'成功' if titan_success else '失敗'}")
    
    if not claude_success or not titan_success:
        print("\n一部のモデルへのアクセスが失敗しました。")
        print("AWSコンソールでモデルアクセスを有効にしてください。")
    else:
        print("\nすべてのモデルテストが成功しました！")

if __name__ == "__main__":
    main()
