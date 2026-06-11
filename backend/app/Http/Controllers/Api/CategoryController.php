<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\CategoryRequest;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class CategoryController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $categories = Category::where('household_id', $request->user()->household_id)->get();

        return CategoryResource::collection($categories);
    }

    public function store(CategoryRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['household_id'] = $request->user()->household_id;

        $category = Category::create($data);

        return response()->json(new CategoryResource($category), 201);
    }

    public function show(Request $request, Category $category): JsonResponse
    {
        $this->authorize($request, $category);

        return response()->json(new CategoryResource($category));
    }

    public function update(CategoryRequest $request, Category $category): JsonResponse
    {
        $this->authorize($request, $category);

        $category->update($request->validated());

        return response()->json(new CategoryResource($category->fresh()));
    }

    public function destroy(Request $request, Category $category): JsonResponse
    {
        $this->authorize($request, $category);

        $category->delete();

        return response()->json(null, 204);
    }

    private function authorize(Request $request, Category $category): void
    {
        if ($category->household_id !== $request->user()->household_id) {
            abort(403);
        }
    }
}
