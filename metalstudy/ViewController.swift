
import Cocoa
import MetalKit

class ViewController: NSViewController {
    
    private let device = MTLCreateSystemDefaultDevice()!
    private let positionData: [Float] = [
        -1.00, +1.00, 0, +1,
         -1.00, -1.00, 0, +1,
         +1.00, +1.00, 0, +1,
         +1.00, +1.00, 0, +1,
         -1.00, -1.00, 0, +1,
         +1.00, -1.00, 0, +1
         
    ]
    
    private let colorData: [Float] = []
    private var commandQueue: MTLCommandQueue!
    private var renderPassDescriptor: MTLRenderPassDescriptor!
    private var bufferPosition: MTLBuffer!
    private var bufferColor: MTLBuffer!
    private var renderPipelineState: MTLRenderPipelineState!
    private var metalLayer: CAMetalLayer!;
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 1920, height: 1080))
        view.layer = CALayer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayer();
        setupMetal()
        makeBuffers()
        makePipeline()
        draw();
    }
    private func initLayer(){
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer!.frame
        view.layer!.addSublayer(metalLayer)
    }
    private func setupMetal() {
        commandQueue = device.makeCommandQueue()
        renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadAction.clear
        renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreAction.store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0)
    }
    private func makeBuffers() {
        let size = positionData.count * MemoryLayout<Float>.size
        bufferPosition = device.makeBuffer(bytes: positionData, length: size)
        bufferColor = device.makeBuffer(bytes: colorData, length: size)
    }
    
    private func makePipeline() {
        guard let library = device.makeDefaultLibrary() else {fatalError()}
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "myVertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "myFragmentShader")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)
    }
    func draw() {
        guard let drawable = metalLayer.nextDrawable() else {fatalError()}
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        guard let cBuffer = commandQueue.makeCommandBuffer() else {fatalError()}
        let encoder = cBuffer.makeRenderCommandEncoder(
            descriptor: renderPassDescriptor
        )!
        encoder.setRenderPipelineState(renderPipelineState)
        encoder.setVertexBuffer(bufferPosition, offset: 0, index: 0)
        encoder.setVertexBuffer(bufferColor, offset: 0, index:1)
        encoder.drawPrimitives(type: MTLPrimitiveType.triangle,vertexStart: 0,vertexCount: 6)
        encoder.endEncoding()
        cBuffer.present(drawable)
        cBuffer.commit()
    }
}
