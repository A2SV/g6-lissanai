// app/api/interview/route.ts
import { NextRequest, NextResponse } from "next/server";
import fs from "fs";
import path from "path";

export async function POST(req: NextRequest) {
  try {
    // Check if Hugging Face API key is available
    if (!process.env.HUGGINGFACE_API_KEY) {
      return NextResponse.json(
        { error: "Hugging Face API key not configured" },
        { status: 500 }
      );
    }

    // Get the form data
    const formData = await req.formData();
    const file = formData.get("file") as File;

    if (!file) {
      return NextResponse.json(
        { error: "No audio file provided" },
        { status: 400 }
      );
    }

    // Convert File to Buffer
    const bytes = await file.arrayBuffer();
    const buffer = Buffer.from(bytes);

    // Create uploads directory if it doesn't exist
    const uploadsDir = path.join(process.cwd(), "uploads");
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }

    // Create a temporary file path with shorter name
    const tempFilePath = path.join(uploadsDir, `audio_${Date.now()}.webm`);
    
    // Write buffer to file
    fs.writeFileSync(tempFilePath, buffer);

    try {
      // Read the file and send it directly to Hugging Face API
      const fileBuffer = fs.readFileSync(tempFilePath);
      
      // Call Hugging Face Whisper API with file data and correct content type
      const response = await fetch(
        "https://api-inference.huggingface.co/models/openai/whisper-large-v3",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${process.env.HUGGINGFACE_API_KEY}`,
            "Content-Type": "audio/webm",
            "X-Wait-For-Model": "true", // important: wait for cold start
          },
          body: fileBuffer,
        }
      );

      if (!response.ok) {
        const errorBody = await response.text(); // read raw text to avoid JSON-only errors
        console.error("Hugging Face API error:", errorBody);
        return NextResponse.json(
          { error: `HF ${response.status}: ${errorBody.slice(0, 500)}` },
          { status: 500 }
        );
      }

      const data = await response.json();
      // Handle both {text} and array responses defensively
      const text =
        (data && data.text) ||
        (Array.isArray(data) && data[0]?.text) ||
        "";
      
      // Clean up the temporary file
      fs.unlinkSync(tempFilePath);

      return NextResponse.json({ text });
    } catch (transcriptionError) {
      // Clean up the temporary file on error
      if (fs.existsSync(tempFilePath)) {
        fs.unlinkSync(tempFilePath);
      }
      throw transcriptionError;
    }
  } catch (error) {
    console.error("Transcription error:", error);
    return NextResponse.json(
      { error: "Failed to transcribe audio" },
      { status: 500 }
    );
  }
}
