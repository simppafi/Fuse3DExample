using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Fuse.Designer;
using Fuse.Entities;
using Fuse.Controls;
using Fuse.Drawing.Primitives;
using Uno.Content.Models;
using Fuse.Drawing.Batching;

public partial class CustomRenderNode
{
	public Frustum CameraFrustum {get;set;}
	public Transform3D CameraTransform {get;set;}

	public CustomRenderNode()
	{
		InitializeUX();

		UpdateManager.AddAction(Initialize);
	}

	private Batch				Geom;

	private void Initialize()
	{
		UpdateManager.RemoveAction(Initialize);

		// SETUP EVERYTHING

		// CREATE GEOMETRY
		var p = new [] { float3(-1,-1,1), float3(1,-1,1), float3(1,1,1), float3(-1,1,1) };
		var vertices = new List<float3>();
		var indices = new List<int3>();
		int i;
		for(i = 0; i < 8; i++)
		{
			vertices.Add(p[i%4] * (i > 3 ? float3(1f) : float3(1,1,-1)));
		}

		indices.Add(int3(0,2,1)); indices.Add(int3(0,3,2)); indices.Add(int3(1,2,6)); indices.Add(int3(6,5,1));
        indices.Add(int3(4,5,6)); indices.Add(int3(6,7,4)); indices.Add(int3(2,3,6)); indices.Add(int3(6,3,7));
        indices.Add(int3(0,7,3)); indices.Add(int3(0,4,7)); indices.Add(int3(0,1,5)); indices.Add(int3(0,5,4));


        //BUILD BATCH
        var cubeCount = 100;
        Geom = new Batch(vertices.Count*cubeCount, indices.Count*3*cubeCount, true);

		float3 v, center, angle, scale;
		var rand = new Random(1);
		int indexAdd = 0;
		
		for(var j = 0; j < cubeCount; j++)
		{
			center = float3(	-40f + 80f * rand.NextFloat(),
								-40f + 80f * rand.NextFloat(),
								-40f + 80f * rand.NextFloat());
			angle = rand.NextFloat3();
			scale = float3(	.5f + 3f * rand.NextFloat(),
							.5f + 3f * rand.NextFloat(),
							.5f + 3f * rand.NextFloat());

			for(i = 0; i < vertices.Count; i++)
			{
				v = vertices[i];

				v *= scale;

				v = Vector.Transform(v, Uno.Quaternion.RotationAxis(angle, Math.PIf*.5f));
				
				Geom.Positions.Write(v + center);

				Geom.Normals.Write(v);
			}

			for(i = 0; i < indices.Count; i++)
			{
				Geom.Indices.Write((ushort)(indices[i].X + indexAdd));
				Geom.Indices.Write((ushort)(indices[i].Y + indexAdd));
				Geom.Indices.Write((ushort)(indices[i].Z + indexAdd));
			}

			indexAdd += vertices.Count;
		}


		UpdateManager.AddAction(OnUpdate);
	}

	private void OnUpdate()
	{
		
	}

	protected override void OnDraw(Fuse.DrawContext dc)
	{
		

		var _camAngle = (float)Fuse.Time.FrameTime * .1f + CamAngle;

		CameraFrustum.FovRadians = Math.PIf/3f;
		CameraTransform.Position = float3(CamRadius * Math.Sin(_camAngle), CamMoveY, CamRadius * Math.Cos(_camAngle));
		CameraTransform.LookAt(float3(0,0,0), float3(0,1,0));
		
		
		draw DefaultShading, Geom {
			
			DrawContext : dc;
			
			DiffuseColor : (Vector.Normalize(pixel WorldPosition) + 1f) * .5f;
			
		};
			


	}


	private float CamMoveY = 0f;
	private float CamAngle = 0f;
	private float CamRadius = 50f;
	private bool PointerIsDown = false;
	private float2 PointerDelta = float2(0);
	private float2 PointerPrevPoint = float2(0);

	public void PointerPressed(object sender, Fuse.Input.PointerPressedArgs args)
	{
		debug_log "pressed";
		PointerPrevPoint = args.WindowPoint;
		PointerIsDown = true;
	}
	public void PointerReleased(object sender, Fuse.Input.PointerReleasedArgs args)
	{
		PointerIsDown = false;
		
		// TO CLICK ON 3D OBJECT
		//var CursorRay = Viewport.PointToWorldRay(args.WindowPoint);
		//var dist = Uno.Geometry.Distance.RayPoint(CursorRay, float3(0,150,0));
		//if(dist < 75)
		//{
		//	
		//}

	}
	public void PointerMoved(object sender, Fuse.Input.PointerMovedArgs args)
	{
		if(PointerIsDown)
		{
			PointerDelta = (args.WindowPoint - PointerPrevPoint);
			PointerPrevPoint = args.WindowPoint;
			
			CamAngle -= PointerDelta.X * .005f;
			CamMoveY += PointerDelta.Y;

		}
	}
	public void PointerWheelMoved(object sender, Fuse.Input.PointerWheelMovedArgs args)
	{

	}



	public int2 GetSize(float resolution, DrawContext dc)
	{
		return int2((int)( Uno.Math.Max(2, dc.RenderTarget.Size.X * resolution)), (int)( Uno.Math.Max(2, dc.RenderTarget.Size.Y * resolution)));
	}


	

}

